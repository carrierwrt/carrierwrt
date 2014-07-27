# (C) 2013 CarrierWrt.org

#
# Product profile: ap (Access Point)
#

define Product/ap

	CONFIG += \
		CONFIG_BUSYBOX_CONFIG_TELNETD=n \
		CONFIG_PACKAGE_wpad-mini=n \
		CONFIG_PACKAGE_wpad=y \
		CONFIG_PACKAGE_anyfi-mac=y \
		CONFIG_PACKAGE_easycwmp=y

endef

define Customization/default

	CONFIG += \
		CONFIG_PACKAGE_luci=y \
		CONFIG_PACKAGE_luci-theme-bootstrap=y \
		CONFIG_PACKAGE_luci-branding=y

	TESTED := \
		ar71xx/openwrt-ar71xx-generic-ubnt-nano-m-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-ubnt-nano-m-squashfs-sysupgrade.bin \
		ar71xx/openwrt-ar71xx-generic-ubnt-rocket-m-squashfs-factory.bin \
		ar71xx/openwrt-ar71xx-generic-ubnt-rocket-m-squashfs-sysupgrade.bin

endef

define Customization/managed
	$(call Customization/default)

	TR69_MIGR_DIR := $(OPENWRT_DIR)/files/etc/uci-migrations/1.1.3-6
endef

define Customization/managed/prebuild
	rm $(TR69_MIGR_DIR)/01-tr69-set-dhcp-option43.sh
	cp common/uci-migrations/tr69/set-fixed-acs.sh $(TR69_MIGR_DIR)/01-tr69-set-fixed-acs.sh
endef
