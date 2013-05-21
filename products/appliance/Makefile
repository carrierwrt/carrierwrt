
# (C) 2013 CarrierWrt.org

#
# Product profile: appliance (Network Appliance)
#

define Product/appliance

	CONFIG += CONFIG_PACKAGE_anyfi=y

	SETTINGS := uci-product.sh

endef

define Customization/default

	CONFIG += 
	
	SETTINGS := uci-customization.sh

	TESTED := \
		x86/openwrt-x86-generic-combined-ext4.img.gz \
		x86/openwrt-x86-generic-combined-ext4.vdi \
		x86/openwrt-x86-generic-combined-ext4.vmdk \
		x86/openwrt-x86-generic-combined-squashfs.img

endef
