
append HEALTHCHECKS easycwmp_staying_alive

easycwmp_is_running() {
	ps | grep -v 'grep' | grep -q 'easycwmp'
}

easycwmp_is_configured() {
	uci get easycwmp.@local[0].interface	2>&1 > /dev/null || return 1
	uci get easycwmp.@local[0].port		2>&1 > /dev/null || return 1
	
	uci get easycwmp.@acs[0].scheme		2>&1 > /dev/null || return 1
	uci get easycwmp.@acs[0].hostname	2>&1 > /dev/null || return 1
	uci get easycwmp.@acs[0].port		2>&1 > /dev/null || return 1
	
	return 0
}

easycwmp_staying_alive() {
	if ! easycwmp_is_running; then
		# If it was configured then it must have died:
		easycwmp_is_configured && return 1
	fi
	
	return 0
}
