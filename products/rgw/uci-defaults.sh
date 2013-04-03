#!/bin/sh

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Set up wireless with MAC as default password
uci set wireless.radio0.disabled=0
uci set wireless.@wifi-iface[0].ssid="CarrierWrt<$(echo $MAC | cut -c10-15)>"
uci set wireless.@wifi-iface[0].encryption=psk2
uci set wireless.@wifi-iface[0].key="$(echo $MAC | sed 's/://g')"
uci commit wireless

exit 0
