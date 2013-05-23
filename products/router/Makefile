
# (C) 2013 CarrierWrt.org

#
# Product profile: router (Consumer Wi-Fi Router)
#

define Product/router

	CONFIG += \
		CONFIG_PACKAGE_luci=y \
		CONFIG_PACKAGE_anyfi=y
			
	SETTINGS := uci-product.sh

endef

define Customization/default

	CONFIG += \
		CONFIG_PACKAGE_luci-theme-bootstrap=y
	
	SETTINGS := uci-customization.sh

	TESTED := \
		ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr2543-v1-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr2543-v1-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-wndr3700v2-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-wndr3700v2-squashfs-sysupgrade.bin

endef
