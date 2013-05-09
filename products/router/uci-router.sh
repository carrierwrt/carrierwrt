#!/bin/sh

# Set product as hostname
uci set system.@system[0].hostname=carrier-router
uci commit system
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

exit 0
