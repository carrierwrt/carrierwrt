#!/bin/sh

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Set up wireless as open network per default
uci set wireless.radio0.disabled=0
uci set wireless.@wifi-iface[0].ssid="CarrierWrt<$(echo $MAC | cut -c10-15)>"
uci commit wireless

# Set bootstrap as theme in luci
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci

exit 0
