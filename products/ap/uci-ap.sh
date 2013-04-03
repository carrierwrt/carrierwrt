#!/bin/sh

LANIFS=$(uci get network.lan.ifname)
WANIFS=$(uci get network.wan.ifname)

# Move all wired interfaces to wan
uci set network.lan.ifname=""
uci set network.wan.type="bridge"
uci set network.wan.ifname="$LANIFS $WANIFS"
uci commit network

# Move all wireless interfaces to wan
I=0
while [ "$(uci get wireless.@wifi-iface[$I])" = "wifi-iface" ]
do
	if [ "$(uci get wireless.@wifi-iface[$I].network)" = "lan" ]
	then
		uci set wireless.@wifi-iface[$I].network=wan
	fi
	I=$((I + 1))
done
uci commit wireless

# Set product as hostname
uci set system.@system[0].hostname=carrier-ap
uci commit system
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

exit 0
