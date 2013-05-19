#!/bin/sh

MAC=$(uci get wireless.radio0.macaddr | tr 'a-f' 'A-F')

# Set up wireless as open network per default
uci delete wireless.radio0.disabled
uci set wireless.@wifi-iface[0].ssid="carrierwrt-$(echo $MAC | cut -c10-17 | tr -d ':')"
uci commit wireless

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
uci commit firewall

# Set bootstrap as theme in luci
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci

exit 0
