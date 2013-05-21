#!/bin/sh

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Set up wireless with random default passphrase
uci delete wireless.radio0.disabled
uci set wireless.radio0.anyfi_server=anyfi.net
uci set wireless.@wifi-iface[0].ssid="carrierwrt-$(echo $MAC | cut -c10-17 | tr -d ':')"
uci set wireless.@wifi-iface[0].encryption=psk-mixed
uci set wireless.@wifi-iface[0].key="$(tr -cd 'a-zA-Z0-9' < /dev/urandom | head -c 8)"
uci set wireless.@wifi-iface[0].anyfi_server=anyfi.net
uci commit wireless

# Set bootstrap as theme in luci
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci

exit 0
