#!/bin/sh

# Set bootstrap as theme in luci
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci

exit 0
