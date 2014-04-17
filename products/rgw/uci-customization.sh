#!/bin/sh

SAVE=/etc/factory-defaults/save
PERSIST=/etc/factory-defaults/persist

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Initialize persistent variables
[ -e $PERSIST/SSID ] || \
	echo "carrierwrt-$(echo $MAC | cut -c10-17 | tr -d ':')" > $PERSIST/SSID
[ -e $PERSIST/KEY ] || \
	tr -cd 'a-zA-Z0-9' < /dev/urandom | head -c 8 > $PERSIST/KEY

if [ ! -e $SAVE/CUSTOMIZATION ]; then
	# Set up wireless with WPA/WPA2-PSK
	uci delete wireless.radio0.disabled
	uci set wireless.@wifi-iface[0].ssid="$(cat $PERSIST/SSID)"
	uci set wireless.@wifi-iface[0].encryption=psk-mixed
	uci set wireless.@wifi-iface[0].key="$(cat $PERSIST/KEY)"
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
