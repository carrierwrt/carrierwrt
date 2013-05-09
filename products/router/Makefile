
# (C) 2013 CarrierWrt.org

#
# Product profile: router (Consumer Wi-Fi Router)
#

define Product/router

  CONFIG += \
  		CONFIG_PACKAGE_luci=y
		  
  SETTINGS := uci-router.sh

endef

define Customization/default

  CONFIG += \
		CONFIG_PACKAGE_luci-theme-bootstrap=y
	
  SETTINGS := uci-defaults.sh

  TESTED := \
    ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-factory.bin \
    ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-sysupgrade.bin 

endef
