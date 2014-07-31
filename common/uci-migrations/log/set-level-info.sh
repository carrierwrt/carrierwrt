#!/bin/sh

# Set log level to INFO with 32kb ring buffer
uci set system.@system[0].conloglevel=7
uci set system.@system[0].log_size=32
uci commit system

exit 0
