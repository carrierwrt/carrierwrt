
# OpenWrt SVN revision/branch/tag
CONFIG_OPENWRT_PATH = branches/barrier_breaker
CONFIG_OPENWRT_REV  = 44952

# LuCI SVN revision/branch/tag
#CONFIG_LUCI_PATH = branches/luci-0.11+svn9964
#CONFIG_LUCI_REV  = 2
CONFIG_LUCI_LIST = luci

# Packages revision/branch/tag
#CONFIG_PACKAGES_PATH = /branches/packages_12.09
#CONFIG_PACKAGES_REV  = $(CONFIG_OPENWRT_REV)
CONFIG_PACKAGES_LIST = libmicroxml libpolarssl

# Base configuration
CONFIG = \
	CONFIG_BUSYBOX_CONFIG_WATCHDOG=n \
	CONFIG_PACKAGE_watchdog=y \
	CONFIG_PACKAGE_libmicroxml=y
