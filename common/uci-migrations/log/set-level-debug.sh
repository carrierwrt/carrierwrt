#!/bin/sh

# Set log level to DEBUG with 320kb ring buffer
uci set system.@system[0].conloglevel=8
uci set system.@system[0].log_size=320
uci commit system

exit 0
