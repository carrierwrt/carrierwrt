#!/bin/sh

SAVE=/etc/factory-defaults/save

if [ ! -e $SAVE/PRODUCT ]; then
	# Set LAN ip address to mimize risk of collision
	uci set network.lan.ipaddr=192.168.8.1
	uci commit network

	# Set product as hostname
	uci set system.@system[0].hostname=carrier-rgw
	uci commit system
	echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

	echo 'rgw' > $SAVE/PRODUCT
fi

exit 0
