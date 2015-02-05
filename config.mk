
# OpenWrt SVN revision/branch/tag
CONFIG_OPENWRT_PATH = branches/barrier_breaker
CONFIG_OPENWRT_REV  = 43057

# Base configuration
CONFIG = \
	CONFIG_PACKAGE_factory-defaults=y \
	CONFIG_BUSYBOX_CONFIG_WATCHDOG=n \
	CONFIG_PACKAGE_watchdog=y
