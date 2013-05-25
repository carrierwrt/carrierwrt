#!/bin/sh

SAVE=/etc/factory-defaults/save
PERSIST=/etc/factory-defaults/persist

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Initialize persistent variables
[ -e $PERSIST/SSID ] || \
	echo "carrierwrt-$(echo $MAC | cut -c10-17 | tr -d ':')" > $PERSIST/SSID

# Customize (if we haven't already)
if [ ! -e $SAVE/CUSTOMIZATION ]; then

	# Set up wireless
	uci delete wireless.radio0.disabled
	uci set wireless.radio0.anyfi_server=anyfi.net
	uci set wireless.@wifi-iface[0].ssid="$(cat $PERSIST/SSID)"
	uci set wireless.@wifi-iface[0].anyfi_server=anyfi.net
	uci commit wireless || exit 1

	# Open up firewall so that AP can be managed over WAN
	uci add firewall rule
	uci set firewall.@rule[-1].name='Allow HTTP from WAN'
	uci set firewall.@rule[-1].src=wan
	uci set firewall.@rule[-1].target=ACCEPT
	uci set firewall.@rule[-1].proto=tcp
	uci set firewall.@rule[-1].dest_port=80
	uci add firewall rule
	uci set firewall.@rule[-1].name='Allow SSH from WAN'
	uci set firewall.@rule[-1].src=wan
	uci set firewall.@rule[-1].target=ACCEPT
	uci set firewall.@rule[-1].proto=tcp
	uci set firewall.@rule[-1].dest_port=22
	uci commit firewall || exit 1

	# Set bootstrap as theme in luci
	uci set luci.main.mediaurlbase=/luci-static/bootstrap
	uci commit luci || exit 1

	echo '' > $SAVE/CUSTOMIZATION
fi

exit 0
