#!/bin/sh

# Set dumb default ssid / key
uci set wireless.radio0.disabled=0
uci set wireless.@wifi-iface[0].ssid=carrierwrt
uci set wireless.@wifi-iface[0].encryption=psk2
uci set wireless.@wifi-iface[0].key=carrierwrt
uci commit wireless

# Open up firewall so that above can be changed
uci add firewall rule
uci set firewall.@rule[-1].src=wan
uci set firewall.@rule[-1].target=ACCEPT
uci set firewall.@rule[-1].proto=tcp
uci set firewall.@rule[-1].dest_port=80
uci commit firewall

exit 0
