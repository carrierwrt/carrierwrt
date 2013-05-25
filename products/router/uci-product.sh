#!/bin/sh

SAVE=/etc/factory-defaults/save

if [ ! -e $SAVE/PRODUCT ]; then
	# Set product as hostname
	uci set system.@system[0].hostname=carrier-router
	uci commit system
	echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

	echo 'router' > $SAVE/PRODUCT
fi

exit 0
