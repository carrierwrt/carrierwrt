
# OpenWrt SVN revision/branch/tag
CONFIG_OPENWRT_PATH = branches/barrier_breaker
CONFIG_OPENWRT_REV  = 43057

CONFIG_FEED_PACKAGES = luci libmicroxml

# Base configuration
CONFIG = \
	CONFIG_BUSYBOX_CONFIG_WATCHDOG=n \
	CONFIG_PACKAGE_watchdog=y
