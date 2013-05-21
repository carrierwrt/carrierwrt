#!/bin/sh
#
# Copyright (C) 2013 Anyfi Networks AB.
#
# Anyfi.net Virtual Wi-Fi Device Driver
# =====================================
#
# Anyfi.net is an open Wi-Fi mobility platform that lets you seamlessly access
# your favourite Wi-Fi networks remotely. But it can also be used for carrier
# Wi-Fi applications. With carrier Wi-Fi you typically want to connect very
# many devices to a central location, e.g. the mobile core or a data center.
# This "virtual Wi-Fi device driver" lets you do that by giving you a virtual
# radio to configure with the SSID and security settings that you want for your
# virtual Wi-Fi network. The network will of course not have any local
# representation (since there is no Wi-Fi radio), but can still be distributed
# through an infinite number of Anyfi.net enabled access points.

append DRIVERS "any80211"

detect_any80211() {
	local cfg
	config_load wireless

	for cfg in $CONFIG_SECTIONS; do
		[ "$(config_get $cfg type)" = any80211 ] && return 0
	done

	cat <<EOF
config wifi-device 'virtual0'
	option type 'any80211'
	option disabled '1'
		
config wifi-iface
	option device 'virtual0'
	option network 'lan'
	option ssid 'Virtual Wi-Fi Network'
	option encryption 'none'
EOF
}

scan_any80211() {
	return 0
}

enable_any80211() {
	return 0
}

disable_any80211() {
	return 0
}
