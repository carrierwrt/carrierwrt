# (C) 2013 CarrierWrt.org

#
# Product profile: ap (Access Point)
#

define Product/ap

  CONFIG += \
		CONFIG_PACKAGE_wpad=y \
		CONFIG_PACKAGE_wpad-mini=n \
		CONFIG_BUSYBOX_CONFIG_TELNETD=n

  SETTINGS := uci-product.sh

endef

define Customization/default

  CONFIG += \
  		CONFIG_PACKAGE_luci=y \
  		CONFIG_PACKAGE_luci-theme-bootstrap=y

  SETTINGS := uci-customization.sh

  TESTED := \
    ar71xx/openwrt-ar71xx-generic-ubnt-nano-m-squashfs-factory.bin \
    ar71xx/openwrt-ar71xx-generic-ubnt-nano-m-squashfs-sysupgrade.bin \
    ar71xx/openwrt-ar71xx-generic-ubnt-rocket-m-squashfs-factory.bin \
    ar71xx/openwrt-ar71xx-generic-ubnt-rocket-m-squashfs-sysupgrade.bin

endef
