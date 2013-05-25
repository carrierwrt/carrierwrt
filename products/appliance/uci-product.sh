#!/bin/sh

SAVE=/etc/factory-defaults/save

if [ ! -e $SAVE/PRODUCT ]; then
	# Set product as hostname
	uci set system.@system[0].hostname=carrier-appliance
	uci commit system
	echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

	echo 'appliance' > $SAVE/PRODUCT
fi

exit 0
