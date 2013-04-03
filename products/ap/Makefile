# (C) 2013 CarrierWrt.org

#
# Product profile: AP (Access Point)
#

define Product/ap

  CONFIG += \
		CONFIG_PACKAGE_wpad=y \
		CONFIG_PACKAGE_wpad-mini=n \
		CONFIG_BUSYBOX_CONFIG_TELNETD=n

  SETTINGS = uci-ap.sh

endef

define Customization/default

  CONFIG += CONFIG_PACKAGE_luci=y

  SETTINGS = uci-defaults.sh

endef
