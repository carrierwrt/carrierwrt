#!/bin/sh

# TR-069 ACS will come through DHCP Option 43
uci set network.wan.vendorid="carrierwrt.org dslforum.org"
uci set network.wan.reqopts=43
uci commit network

exit 0
