#!/bin/sh

SAVE=/etc/factory-defaults/save
PERSIST=/etc/factory-defaults/persist

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Initialize persistent variables
[ -e $PERSIST/SSID ] || \
	echo "carrierwrt-$(echo $MAC | cut -c10-17 | tr -d ':')" > $PERSIST/SSID

if [ ! -e $SAVE/CUSTOMIZATION ]; then
	# Set up wireless as open network per default
	uci delete wireless.radio0.disabled
	uci set wireless.@wifi-iface[0].ssid="$(cat $PERSIST/SSID)"
	uci commit wireless

	# Set anyfi controller (default is demo.anyfi.net)
	#uci set anyfi.controller.hostname="your.own.controller"
	#uci commit anyfi

	# Set bootstrap as theme in luci
	uci set luci.main.mediaurlbase=/luci-static/bootstrap
	uci commit luci

	echo '' > $SAVE/CUSTOMIZATION
fi

exit 0
