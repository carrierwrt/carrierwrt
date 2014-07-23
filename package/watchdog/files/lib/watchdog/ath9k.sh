
append HEALTHCHECKS ath9k_intrs_working

ATH9K_RESETS=0

ath9k_intrs_working() {
	local debugfs=/sys/kernel/debug/ieee80211/phy0/ath9k
	
	if grep -q "^VIF-COUNTS: AP: [1-9]" $debugfs/misc 2> /dev/null; then
		local intrs=$(cat $debugfs/interrupt | head -8)
		
		if [ "$intrs" == "$ATH9K_PREV_INTRS" ]; then
			echo 1 > $debugfs/reset
			ATH9K_RESETS=$(($ATH9K_RESETS + 1))
		else
			ATH9K_RESETS=0
		fi
			
		ATH9K_PREV_INTRS="$intrs"
	fi
	
	if [ "$ATH9K_RESETS" -gt 10 ]; then
		return 1
	else
		return 0
	fi
}
