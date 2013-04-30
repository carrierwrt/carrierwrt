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

  CONFIG += \
  		CONFIG_PACKAGE_luci=y \
  		CONFIG_PACKAGE_luci-theme-bootstrap=y

  SETTINGS = uci-defaults.sh

  # Don't build for TL since they are impossible to flash without webui/telnet/ssh
  IMAGES := $(filter-out ar71xx/openwrt-ar71xx-generic-tl-%, $(IMAGES))

endef
