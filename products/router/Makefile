
# (C) 2013-2014 CarrierWrt.org

#
# Product profile: router (Consumer Wi-Fi Router)
#

define Product/router

	CONFIG += \
		CONFIG_PACKAGE_luci=y \
		CONFIG_PACKAGE_anyfi-mac=y
			
endef

define Customization/default

	CONFIG += \
		CONFIG_PACKAGE_luci-theme-bootstrap=y \
		CONFIG_PACKAGE_luci-branding=y
	
	TESTED := \
		ar71xx/openwrt-ar71xx-generic-tl-wr841nd-v5-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr841nd-v5-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr841n-v8-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr841n-v8-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr941nd-v2-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr2543-v1-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wr2543-v1-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-wndr3700v2-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-wndr3700v2-squashfs-sysupgrade.bin

endef

define Customization/debug
	$(call Customization/default)

	CONFIG += \
		CONFIG_BUSYBOX_CONFIG_FEATURE_INIT_COREDUMPS=y \
		CONFIG_PACKAGE_ATH_DEBUG=y \
		CONFIG_PACKAGE_hostapd-utils=y

endef

define Customization/debug/prebuild
	touch $(OPENWRT_DIR)/files/.init_enable_core
endef
