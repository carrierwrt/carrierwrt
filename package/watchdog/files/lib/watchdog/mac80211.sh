
append HEALTHCHECKS mac80211_no_warnings

mac80211_no_warnings() {

	if dmesg | grep -q 'WARNING.*compat-wireless'; then 
		# WARN_ON()s indicative of mac80211 muteness syndrome:
		#
		#  WARNING: at /.../compat-wireless-2014-01-23.1/net/mac80211/ieee80211_i.h:843
		#  WARNING: at /.../compat-wireless-2014-01-23.1/net/mac80211/rate.h:65
		#
		return 1
	else
		return 0
	fi
}
