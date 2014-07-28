#!/bin/sh
#
# This script migrates uci settings from the old to the new anyfi uci model.
#

### Settings to migrate:

CONTROLLER=""

### Old model:

list_type() {
        uci show wireless | grep "=$1" | cut -f2 -d'.' | cut -f1 -d'='
}

DEVICES=$(list_type wifi-device)
IFACES=$(list_type wifi-iface)

for DEV in $DEVICES; do
	ctrl="$(uci get wireless.$DEV.anyfi_server)"

	if [ -z "$ctrl" ]; then
		# No anyfi_server in old model used to mean disable:
		[ "$UCI_MIGRATION_ACTION" == "UPGRADE" ] && \
			uci set wireless.$DEV.anyfi_disabled=1
	else
		if [ -z "$CONTROLLER" ]; then
			CONTROLLER="$ctrl"
		elif [ "$CONTROLLER" != "$ctrl" ]; then
			echo "Warning: Cannot migrate more than one controller!"
		fi
	fi
	uci delete wireless.$DEV.anyfi_server 2> /dev/null

	# Downling and uplink estimation is so good now that
	# it makes sense to delete the overrides (if any):
	uci delete wireless.$DEV.anyfi_uplink 2> /dev/null
	uci delete wireless.$DEV.anyfi_downlink 2> /dev/null
done

for VIF in $IFACES; do
	ctrl="$(uci get wireless.$VIF.anyfi_server)"

	if [ -z "$ctrl" ]; then
		# No anyfi_server in old model used to mean disabled:
		[ "$UCI_MIGRATION_ACTION" == "UPGRADE" ] && \
			uci set wireless.$VIF.anyfi_disabled=1
	else
		if [ -z "$CONTROLLER" ]; then
			CONTROLLER="$ctrl"
		elif [ "$CONTROLLER" != "$ctrl" ]; then
			echo "Warning: Cannot migrate more than one controller!"
		fi
	fi
	uci delete wireless.$VIF.anyfi_server 2> /dev/null
done

uci commit wireless

# New model:

if [ -n "$CONTROLLER" ]; then
	uci set anyfi.controller.hostname="$CONTROLLER"
	uci commit anyfi
fi

exit 0
