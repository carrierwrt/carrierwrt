#!/bin/sh

# Open firewall for TR-069
uci add firewall rule
uci set firewall.@rule[-1].name='Allow TR-069 from WAN'
uci set firewall.@rule[-1].src=wan
uci set firewall.@rule[-1].target=ACCEPT
uci set firewall.@rule[-1].proto=tcp
uci set firewall.@rule[-1].dest_port=7547
uci commit firewall

exit 0
