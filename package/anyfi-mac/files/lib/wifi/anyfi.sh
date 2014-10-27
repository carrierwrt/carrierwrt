#!/bin/sh
#
# Copyright (C) 2013-2014 Anyfi Networks AB.
#
# Overview of the Integration
# ===========================
#
# Anyfi.net software consists of two user space daemons; the radio daemon
# anyfid and the tunnel termination daemon myfid. They communicate with each
# other and with a Controller [1] over UDP/IP.
#
# The radio daemon anyfid provides guests with access to remote Wi-Fi networks.
# It needs a Wi-Fi monitor interface to detect when guest devices come within
# range and a pool of virtual access points to serve them. The integration is
# responsible for creating the monitor interface and the pool of virtual access
# points; anyfid handles the rest.
#
# The tunnel termination daemon myfid provides remote access to the local Wi-Fi
# network. It is up to the integration to configure myfid to authenticate remote
# devices in the same way that devices are authenticated when connecting
# locally.
#
# Myfid is also responsible for telling the controller the MAC address of
# devices that connect locally, so that they can later be offered seamless
# remote access whenever they come close to another access point running anyfid.
# However, when the user changes the WPA passphrase all such associations
# between previously connected devices and the local Wi-Fi network should be
# removed. The integration does so by passing myfid the --reset flag.
#
# Below is the integration logic in pseudo code. If you need to integrate
# Anyfi.net software in your own firmware build environment you can find step
# by step instructions at http://anyfi.net/integration.
#
# 1. A Community Edition of the Controller is available for download at
#    http://www.anyfinetworks.com/download. You can also use the public
#    demonstration controller at "demo.anyfi.net".
#
#
# Integration Logic in Pseudo Code
# ================================
#
# After enabling a Wi-Fi device:
#   IF a controller is configured AND Anyfi.net is not disabled
#     ALLOCATE monitor interface and virtual access point pool for anyfid
#     START anyfid
#
#   FOREACH Wi-Fi interface of this device
#     IF a controller is configured AND Anyfi.net is not disabled
#      GENERATE a config file for myfid
#
#      IF the WPA passphrase has changed
#        ADD the --reset flag to myfid arguments
#
#      START myfid on the Wi-Fi interface
#
# After disabling a Wi-Fi device:
#   STOP anyfid
#
#   FOREACH Wi-Fi interface of this device
#     STOP myfid on the Wi-Fi interface
#
# NOTE 1: The integration provides remote access to all Wi-Fi interfaces on the
#         system that have anyfi_disabled set to 0. Each interface will have
#         its own myfid daemon. There should however only be one anyfid daemon
#         per radio.
#
# NOTE 2: On concurrent dual band routers each radio should have its own anyfid
#         daemon.
#
#
# Anyfi.net UCI data model
# ========================
#
# Anyfi.net global parameters:
#
#   Name            Type        Default         Description
#   controller
#      .hostname    IP or FQDN  demo.anyfi.net  Controller IP or FQDN
#      .key         path        -               Controller public key PEM file
#   optimizer
#      .key         path        -               Optimizer public key PEM file
#
# Wi-Fi device parameters:
#
#   Name            Type     Default  Description
#   anyfi_disabled  boolean  0        Enable/disable guest access on this radio
#   anyfi_iface     port     -        Bind anyfid to a WAN interface IP address
#   anyfi_port      number   -        Bind anyfid to a SDWN UDP port
#   anyfi_floor     percent  5        Min backhaul and spectrum allocation
#   anyfi_ceiling   percent  75       Max backhaul and spectrum allocation
#   anyfi_uplink    integer  -        WAN uplink capacity in bits per second
#   anyfi_downlink  integer  -        WAN downlink capacity in bits per second
#   anyfi_bssids    integer  -        Max number of virtual interfaces to use
#   anyfi_clients   integer  -        Max number of concurrent guest users
#
# Wi-Fi interface parameters:
#
#   Name               Type    Default  Description
#   anyfi_disabled     boolean 0        Enable remote access on this network
#   anyfi_iface        string  -        Bind myfid to a WAN interface IP
#                                       address
#   anyfi_port         port    -        Bind myfid to a SDWN UDP port
#   anyfi_autz_server  IP      -        RADIUS authorization server IP
#   anyfi_autz_port    port    1812     RADIUS authorization server UDP port
#   anyfi_autz_secret  string  -        RADIUS authorization server shared
#                                       secret
#   anyfi_acct_server  IP      -        RADIUS extra accounting server IP
#   anyfi_acct_port    port    1813     RADIUS extra accounting server UDP port
#   anyfi_acct_secret  string  -        RADIUS extra accounting server shared
#                                       secret

append ENABLE_HOOKS anyfi_enable
append DISABLE_HOOKS anyfi_disable

# Daemon run dir for temporary files.
RUNDIR=/var/run

# Config file dir for persistent configuration files.
CONFDIR=/etc

##### Wi-Fi device handling ##################################################

# Get the channel for Wi-Fi device.
# anyfi_dev_get_channel <device>
anyfi_dev_get_channel() {
	local device="$1"
	local hwmode channel

	config_get hwmode  "$device" hwmode
	config_get channel "$device" channel

	if [ "$channel" = auto -o "$channel" = 0 ]; then
		case "$hwmode" in
		auto)
			channel=auto
			;;

		*b*|*g*)
			channel=auto2
			;;

		*a*)
			channel=auto5
			;;
		esac
	fi
	echo "$channel"
}

# Start the Anyfi.net radio head daemon anyfid on a device.
# anyfi_dev_start <device> <type> <controller> <controller_key>
anyfi_dev_start()
{
	local device="$1"
	local type="$2"
	local controller="$3"
	local controller_key="$4"
	local nvifs bssids monitor iflist

	# Determine how many virtual interfaces we should use
	config_get bssids "$device" anyfi_bssids
	nvifs=$(echo $(config_get "$device" vifs) | wc -w)

	if [ -n "$bssids" ]; then
		# Limit the number of virtual interfaces to 32
		[ "$bssids" -lt 32 ] || bssids=32
	elif [ $nvifs -lt 4 ]; then
		# Don't use more that 8 interfaces in total if possible...
		bssids=$((8 - $nvifs))
	else
		# ...but try to allocate at least 4 interfaces for anyfid.
		bssids=4
	fi

	# ALLOCATE monitor and pool of virtual access points
	if monitor=$(anyfi_${type}_alloc_monitor "$device") && \
	   iflist=$(anyfi_${type}_alloc_iflist "$device" $bssids)
	then
		local args=""
		local vifs wanif port floor ceiling uplink downlink clients

		config_get vifs     "$device" vifs
		config_get wanif    "$device" anyfi_iface
		config_get port     "$device" anyfi_port
		config_get floor    "$device" anyfi_floor
		config_get ceiling  "$device" anyfi_ceiling
		config_get uplink   "$device" anyfi_uplink
		config_get downlink "$device" anyfi_downlink
		config_get clients  "$device" anyfi_clients

		# If there are no interfaces on this device then
		# anyfid controls channel
		if [ $(echo $vifs | wc -w) -eq 0 ]; then
			args="$args --channel=$(anyfi_dev_get_channel $device)"
		fi

		[ -n "$wanif"    ] && args="$args --bind-if=$wanif"
		[ -n "$port"     ] && args="$args --bind-port=$port"
		[ -n "$floor"    ] && args="$args --floor=$floor"
		[ -n "$ceiling"  ] && args="$args --ceiling=$ceiling"
		[ -n "$uplink"   ] && args="$args --uplink=$uplink"
		[ -n "$downlink" ] && args="$args --downlink=$downlink"
		[ -n "$clients"  ] && args="$args --max-clients=$clients"
		[ -n "$controller_key" ] && \
			args="$args --controller-key=$controller_key"

		# START anyfid
		echo "$device: starting anyfid"
		/sbin/anyfid --accept-license -C "$controller" -B \
		             -P $RUNDIR/anyfid_$device.pid $args \
			     $monitor $iflist
	else
		echo "$device: failed to allocate anyfid interfaces" 1>&2
	fi
}

##### Wi-Fi interface handling ###############################################

# Get the printable name of an interface.
anyfi_vif_get_name() {
	local ifname
	config_get ifname "$1" ifname
	echo "${ifname:-$1}"
}

# Generate the config file for myfid from UCI variables.
# anyfi_vif_gen_config <vif>
anyfi_vif_gen_config() {
	local vif="$1"
	local name="$(anyfi_vif_get_name $1)"
	local device net ssid enc key isolate ifname

	config_get device  "$vif" device
	config_get net     "$vif" network
	config_get ssid    "$vif" ssid
	config_get enc     "$vif" encryption
	config_get key     "$vif" key
	config_get isolate "$vif" isolate
	config_get ifname  "$vif" ifname

	# Check basic settings before proceeding
	[ -n "$net" ] || [ -n "$ssid" ] || return 1

	local auth_proto auth_mode auth_cache group_rekey
	local ciphers wpa_ciphers rsn_ciphers passphrase
	local auth_server auth_port auth_secret
	local autz_server autz_port autz_secret
	local acct_server acct_port acct_secret
	local acct2_server acct2_port acct2_secret
	local radius_nasid

	# Resolve explicit cipher overrides (tkip, ccmp or tkip+ccmp)
	case "$enc" in
	*+tkip+ccmp|*+tkip+aes)
		ciphers=tkip+ccmp
		;;

	*+ccmp|*+aes)
		ciphers=ccmp
		;;

	*+tkip)
		ciphers=tkip
		;;
	esac

	# Resolve authentication protocol (WPA or WPA2)
	case "$enc" in
	psk-mixed*|wpa-mixed*)
		auth_proto=wpa+rsn
		wpa_ciphers=$ciphers
		rsn_ciphers=$ciphers
		;;

	psk2*|wpa2*)
		auth_proto=rsn
		rsn_ciphers=$ciphers
		;;

	psk*|wpa*)
		auth_proto=wpa
		wpa_ciphers=$ciphers
		;;

	none)
		echo "$name: no remote access for security reasons (open network)" 1>&2
		return 1
		;;

	wep*)
		echo "$name: no remote access for security reasons (wep is insecure)" 1>&2
		return 1
		;;

	*)
		echo "$name: unrecognized encryption type $enc" 1>&2
		return 1
		;;
	esac

	# Resolve authenticator mode (PSK or 802.1X)
	case "$enc" in
	psk*)
		auth_mode=psk
		passphrase=$key
		[ -n "$passphrase"  ] || return 1
		;;

	wpa*)
		auth_mode=eap

		config_get auth_server "$vif" auth_server
		config_get auth_port   "$vif" auth_port
		config_get auth_secret "$vif" auth_secret

		config_get acct_server "$vif" acct_server
		config_get acct_port   "$vif" acct_port
		config_get acct_secret "$vif" acct_secret

		config_get auth_cache   "$vif" auth_cache
		config_get group_rekey  "$vif" wpa_group_rekey

		[ -n "$auth_server" ] || return 1
		[ -n "$auth_secret" ] || auth_secret="$key"
		[ -n "$acct_server" -a -z "$acct_secret" ] && acct_secret="$key"
		;;

	none)
		;;

	*)
		echo "$name: no remote access ('encryption' not configured)" 1>&2
		return 1
		;;
	esac

	# Optional RADIUS authorization and accounting for Anyfi.net
	config_get autz_server "$vif" anyfi_autz_server
	config_get autz_port   "$vif" anyfi_autz_port
	config_get autz_secret "$vif" anyfi_autz_secret

	config_get acct2_server "$vif" anyfi_acct_server
	config_get acct2_port   "$vif" anyfi_acct_port
	config_get acct2_secret "$vif" anyfi_acct_secret

	config_get radius_nasid "$vif" radius_nasid

	# Generate common config file options
	cat <<EOF
ssid = '$ssid'
bridge = br-$net
auth_proto = $auth_proto
EOF

	# Generate dependent config file options
	[ "$isolate" = 1     ] && echo "isolation = 1"
	[ -n "$ifname"       ] && echo "local_ap = $ifname"
	[ -n "$auth_mode"    ] && echo "auth_mode = $auth_mode"
	[ -n "$auth_cache"   ] && echo "auth_cache = $auth_cache"
	[ -n "$rsn_ciphers"  ] && echo "rsn_ciphers = $rsn_ciphers"
	[ -n "$wpa_ciphers"  ] && echo "wpa_ciphers = $wpa_ciphers"
	[ -n "$group_rekey"  ] && echo "group_rekey = $group_rekey"
	[ -n "$passphrase"   ] && echo "passphrase = '$passphrase'"
	[ -n "$radius_nasid" ] && echo "radius_nas_id = $radius_nas_id"
	if [ -n "$auth_server"  ] && [ -n "$auth_secret" ]; then
		echo "radius_auth_server = $auth_server"
		echo "radius_auth_port = ${auth_port:-1812}"
		echo "radius_auth_secret = $auth_secret"
	fi
	if [ -n "$acct_server"  ] && [ -n "$acct_secret" ]; then
		echo "radius_acct_server = $acct_server"
		echo "radius_acct_port = ${acct_port:-1813}"
		echo "radius_acct_secret = $acct_secret"
	fi
	if [ -n "$autz_server"  ] && [ -n "$autz_secret" ]; then
		echo "radius_autz_server = $autz_server"
		echo "radius_autz_port = ${autz_port:-1812}"
		echo "radius_autz_secret = $autz_secret"
	fi
	if [ -n "$acct2_server"  ] && [ -n "$acct2_secret" ]; then
		echo "radius_acct2_server = $acct2_server"
		echo "radius_acct2_port = ${acct2_port:-1813}"
		echo "radius_acct2_secret = $acct2_secret"
	fi
	return 0
}

# Get the current value from a myfid configuration file.
# anyfi_vif_get_config <file> <config>
anyfi_vif_get_config() {
	local file="$1"
	local key="$2"

	[ -e "$file" ] || return 1

	# Assume the format is exactly "key = value",
	# where value may or may not be in ''
	grep "$key = " $file | cut -d '=' -f2- | cut -b2- | \
		               sed -e "/^'.*'$/s/^'\\(.*\\)'$/\\1/"
}

# Start the Anyfi.net tunnel-termination daemon myfid on an interface.
# anyfi_vif_start <vif> <controller> <controller_key> <optimizer_key>
anyfi_vif_start()
{
	local vif="$1"
	local controller="$2"
	local controller_key="$3"
	local optimizer_key="$4"

	local name="$(anyfi_vif_get_name $vif)"
	local pid_file="$RUNDIR/myfid_$name.pid"
	local conf_file="$CONFDIR/myfid_$name.conf"
	local new_conf_file="$RUNDIR/myfid_$name.conf"

	# GENERATE a config file for myfid
	if (anyfi_vif_gen_config $vif) > $new_conf_file; then
		local controller_key optimizer_key
		local key old_key wanif port
		local args=""

		config_get key "$vif" key
		config_get wanif "$vif" anyfi_iface
		config_get port "$vif" anyfi_port

		# ADD optional arguments
		[ -n "$wanif" ] && args="$args --bind-if=$wanif"
		[ -n "$port"  ] && args="$args --bind-port=$port"
		[ -n "$controller_key" ] && \
			args="$args --controller-key=$controller_key"
		[ -n "$optimizer_key" ] && \
			args="$args --optimizer-key=$optimizer_key"

		# ADD the --reset flag to myfid arguments if the passphrase
		# has changed or myfid is started for the first time
		old_key="$(anyfi_vif_get_config $conf_file passphrase)"
		[ "$key" == "$old_key" ] || args="$args --reset"

		# Update the myfid config file in flash only if needed
		if ! cmp -s $new_conf_file $conf_file; then
			mv $new_conf_file $conf_file
		else
			rm -f $new_conf_file
		fi

		# START myfid
		echo "$name: starting myfid"
		/sbin/myfid --accept-license -C "$controller" -B -P $pid_file \
		            $args $conf_file
	fi
}

# Stop an Anyfi.net daemon gracefully
# anyfi_stop_daemon <pidfile>
anyfi_stop_daemon() {
	local pidfile="$1"

	kill -TERM $(cat $pidfile)
	for t in $(seq 0 5); do
		[ -e $pidfile ] || return 0
		sleep 1
	done

	echo "Timeout waiting for daemon assocated with $pidfile to exit" 1>&2
	kill -KILL $(cat $pidfile)
	rm -f $pidfile
	return 1
}

# Enable Anyfi.net for a Wi-Fi device.
# Run from ENABLE_HOOKS
anyfi_enable()
{
	local device="$1"
	local controller
	local type vif vifs

	# A controller IP or FQDN is required
	controller="$(uci get anyfi.controller.hostname 2>/dev/null)"
	[ -n "$controller" ] || return 0

	# Optional controller and optimizer keys
	controller_key="$(uci get anyfi.controller.key 2>/dev/null)"
	optimizer_key="$(uci get anyfi.optimizer.key 2>/dev/null)"

	config_get type "$device" type
	config_get vifs "$device" vifs

	# START anyfid on this device
	if [ "$(config_get $device anyfi_disabled)" != 1 ] && \
	   /sbin/anyfi-probe "$type"
	then
		anyfi_dev_start $device $type "$controller" "$controller_key"
	fi

	# FOREACH Wi-Fi interface of this device
	for vif in $vifs; do
		if [ "$(config_get $vif disabled)" != 1 ] && \
		   [ "$(config_get $vif anyfi_disabled)" != 1 ]
		then
			anyfi_vif_start $vif "$controller" \
				        "$controller_key" "$optimizer_key"
		fi
	done
}

# Disable Anyfi.net for a Wi-Fi device.
# Run from DISABLE_HOOKS
anyfi_disable()
{
	local device="$1"
	local type vif vifs

	config_get type "$device" type
	config_get vifs "$device" vifs

	# STOP anyfid on this device (if anyfid is running)
	if [ -e $RUNDIR/anyfid_$device.pid ]; then
		echo "$device: stopping anyfid"
		anyfi_stop_daemon $RUNDIR/anyfid_$device.pid
		anyfi_${type}_release_iflist $device
		anyfi_${type}_release_monitor $device
	fi

	# FOREACH Wi-Fi interface of this device (with myfid running)
	for vif in $vifs; do
		local name="$(anyfi_vif_get_name $vif)"
		local pidfile="$RUNDIR/myfid_$name.pid"

		if [ -e $pidfile ]; then
			echo "$name: stopping myfid"
			anyfi_stop_daemon $pidfile
		fi
	done
}
