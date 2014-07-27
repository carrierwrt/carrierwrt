#!/bin/sh

# Setup TR-069 ACS
uci set easycwmp.@acs[0].path=/
uci set easycwmp.@acs[0].periodic_enable=1
uci set easycwmp.@acs[0].periodic_interval=3600
uci set easycwmp.@acs[0].scheme=https
uci set easycwmp.@acs[0].hostname=acs.carrierwrt.org
uci set easycwmp.@acs[0].port=7548
uci commit easycwmp

# Ensure that TR-069 ACS is not overridden through DHCP Option 43
uci delete network.wan.vendorid
uci delete network.wan.reqopts
uci commit network

exit 0
