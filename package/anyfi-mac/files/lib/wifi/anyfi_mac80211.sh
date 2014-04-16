#!/bin/sh
#
# Copyright (C) 2013-2014 Anyfi Networks AB.
# Anyfi.net setup functions for mac80211 drivers.

# Get monitor name interface based for a device.
# anyfi_dev_monitor_name <device>
anyfi_mac80211_name_monitor() {
	local device="$1"

	# Map radioX => monitorX
	echo "$device" | sed 's/^.*\([0-9]\)$/monitor\1/'
}

# Get name of virtual Wi-Fi interface based on device and index number.
# anyfi_mac80211_name_iface <device> <index>
anyfi_mac80211_name_iface() {
	local device="$1"
	local idx="$2"

	# Map radioX => anyfiX-{0,1,2,3...}
	echo "$device" | sed "s/^.*\([0-9]\)\$/anyfi\1-$idx/"
}

# Allocate virtual Wi-Fi interfaces for anyfid.
# anyfi_mac80211_alloc_iflist <device> <bssids>
anyfi_mac80211_alloc_iflist() {
	local device="$1"
	local bssids="$2"
	local count=0
	local phy hwaddr hwmask start idx

	config_get phy    "$device" phy
	config_get hwaddr "$device" macaddr

	if [ -z "$phy" ] || [ -z "$macaddr" ]; then
		echo "$device: failed to allocate interfaces on $phy" 1>&2
		return 1
	fi

	start=$(echo $(config_get "$device" vifs) | wc -w)
	hwmask=$(cat /sys/class/ieee80211/$phy/address_mask)

	for idx in $(seq 0 $(($bssids - 1))); do
		local ifname mask mac

		ifname=$(anyfi_mac80211_name_iface "$device" $idx)
		mac=$(mac80211_generate_mac $(($start + $idx)) $hwaddr $hwmask)

		iw phy $phy interface add $ifname type __ap || break
		ifconfig $ifname hw ether $mac || break
		count=$(($count + 1))

	done

	[ "$count" -gt 0 ] && \
		echo $(anyfi_mac80211_name_iface "$device" 0)/$count
}

# Release virtual Wi-Fi interfaces allocated for anyfid.
# anyfi_mac80211_release_iflist <device>
anyfi_mac80211_release_iflist() {
	local ifbase=$(anyfi_mac80211_name_iface $1 "")
	local ifaces=$(ifconfig -a | grep -o '^[^ ]\+' | grep $ifbase)
	local ifname

	# Remove our virtual interfaces
	for ifname in $ifaces; do
		ifconfig $ifname down
		iw dev $ifname del
	done
}

# Allocate a monitor interface for anyfid.
# anyfi_mac80211_alloc_monitor <device>
anyfi_mac80211_alloc_monitor() {
	local device="$1"
	local phy=$(config_get "$device" phy)
	local mon=$(anyfi_mac80211_name_monitor "$device")

	if ! ifconfig $mon > /dev/null 2>&1; then
		iw phy $phy interface add $mon type monitor || return 1
	fi
	echo $mon
}

# Release the monitor interface for anyfid.
# anyfi_mac80211_release_monitor <device>
anyfi_mac80211_release_monitor() {
	local device="$1"
	local mon="$(anyfi_mac80211_name_monitor $device)"
	iw dev $mon del > /dev/null 2>&1
}

