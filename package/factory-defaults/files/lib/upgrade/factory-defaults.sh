#!/bin/sh

append sysupgrade_init_persistent do_persist_factory_defaults
do_persist_factory_defaults() {
	local file="$1"
	local f

	# Persist the version of the previous firmware:
	for f in /etc/carrierwrt_*; do
		cp $f /etc/factory-defaults/persist/PREV_$(basename $f)
	done

	ls /etc/factory-defaults/persist/* >> "$file" 2> /dev/null
}

append sysupgrade_init_conffiles do_save_factory_defaults
do_save_factory_defaults() {
	local file="$1"

	ls /etc/factory-defaults/save/* >> "$file" 2> /dev/null
}
