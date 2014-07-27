#!/bin/sh

# Fixup easycwmp WAN interface
if [ "$(uci get network.wan.type 2> /dev/null)" == "bridge" ]; then
	WANIF=br-wan
else
	WANIF=$(uci get network.wan.ifname 2> /dev/null)
fi
uci set easycwmp.@local[0].interface=${WANIF:-wan}
uci commit easycwmp

exit 0
