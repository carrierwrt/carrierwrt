
append HEALTHCHECKS easycwmp_staying_alive

EASYCWMP_RESTARTS=0

easycwmp_is_running() {
	test -n "$(pidof easycwmpd)"
}

easycwmp_is_configured() {
	uci get easycwmp.@local[0].interface 2>&1 > /dev/null || return 1
	uci get easycwmp.@local[0].port      2>&1 > /dev/null || return 1
	
	uci get easycwmp.@acs[0].scheme      2>&1 > /dev/null || return 1
	uci get easycwmp.@acs[0].hostname    2>&1 > /dev/null || return 1
	uci get easycwmp.@acs[0].port        2>&1 > /dev/null || return 1
	
	return 0
}

easycwmp_staying_alive() {
	if ! easycwmp_is_running; then
		# If it was configured then it must have died:
		if easycwmp_is_configured; then
			EASYCWMP_RESTARTS=$(($EASYCWMP_RESTARTS + 1))
			/etc/init.d/easycwmpd start
		fi
	fi
	
	if [ "$EASYCWMP_RESTARTS" -gt 5 ]; then
		return 1
	else
		return 0
	fi
}
