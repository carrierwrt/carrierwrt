
# (C) 2013 CarrierWrt.org

#
# Product profile: Appliance
#

define Product/appliance

  CONFIG += \
		CONFIG_PACKAGE_iw=y \
		CONFIG_PACKAGE_wpad=y \
		CONFIG_PACKAGE_wpad-mini=n

  SETTINGS := uci-appliance.sh

endef

define Customization/default

  CONFIG += \
  		CONFIG_PACKAGE_luci=y \
		CONFIG_PACKAGE_luci-theme-bootstrap=y
	
  SETTINGS := uci-defaults.sh

  TESTED := \
    x86/openwrt-x86-generic-combined-squashfs.img \
    x86/openwrt-x86-generic-combined-ext4.img.gz

endef
