#
# Copyright (C) 2013 CarrierWrt.org
#

include config.mk

# ======================================================================
#  Internal variables
# ======================================================================

V ?= 0

OPENWRT_BASE 	:= svn://svn.openwrt.org/openwrt
OPENWRT_DIR  	:= openwrt
OPENWRT_URL  	:= $(OPENWRT_BASE)/$(CONFIG_OPENWRT_PATH)@$(CONFIG_OPENWRT_REV)
PACKAGES_BASE	:= $(OPENWRT_BASE)
PACKAGES_URL	:= $(PACKAGES_BASE)/$(CONFIG_PACKAGES_PATH)@$(CONFIG_PACKAGES_REV)
LUCI_BASE    	:= http://svn.luci.subsignal.org/luci
LUCI_URL     	:= $(LUCI_BASE)/$(CONFIG_LUCI_PATH)/contrib/package@$(CONFIG_LUCI_REV)
VERSION     	:= $(shell git describe --always | cut -c2-)

FWSUBDIR     	:= $(subst default,,$(CUSTOMIZATION))

# Required packages
CONFIG += CONFIG_PACKAGE_factory-defaults=y

# Copy/override OpenWrt packages with CarrierWrt ditto
# InstallPackages
define InstallPackages
	for package in package/*; do \
		if [ -d $(OPENWRT_DIR)/$$package ]; then \
			rm -rf $(OPENWRT_DIR)/$$package; \
		fi; \
		cp -r $$package $(OPENWRT_DIR)/$$package; \
	done
endef

# WriteConfig <line>
define WriteConfig
	echo $(1) >> $(OPENWRT_DIR)/.config
endef

# Generate an OpenWrt config file for a given target
# Configure <config>
define Configure
	rm -f $(OPENWRT_DIR)/.config
	$(foreach line,$(1),$(call WriteConfig,$(line)) &&) true
	$(MAKE) MAKEOVERRIDES='' -C $(OPENWRT_DIR) defconfig > /dev/null
endef

# CleanImage <image>
define CleanImage
	rm -f $(OPENWRT_DIR)/bin/$(1)
	rm -f firmware/$(PRODUCT)/$(FWSUBDIR)/$(notdir $(1))*
	rm -f firmware/$(PRODUCT)/$(FWSUBDIR)/untested/$(notdir $(1))*
endef

# Clean <images>
define Clean
	$(foreach image,$(1), \
		$(call CleanImage,$(image))
	)
endef

# PatchOne <patchdir>
define PatchOne
	if [ -d $(1)/openwrt ]; then \
		for f in $(1)/openwrt/*; do \
			(cd $(OPENWRT_DIR) && patch -p0 < ../$$f); \
		done; \
	fi
	if [ -d $(1)/package ]; then \
		(cd $(1) && \
		 find package -name '*.patch' \
			 -printf 'mkdir -p $(OPENWRT_DIR)/%h/patches && \
								cp $(1)/%p $(OPENWRT_DIR)/%h/patches/%f\n') | sh; \
	fi
	if [ -d $(1)/feeds ]; then \
		(cd $(1) && \
		 find feeds -name '*.patch' \
			 -printf 'mkdir -p $(OPENWRT_DIR)/%h/patches && \
								cp $(1)/%p $(OPENWRT_DIR)/%h/patches/%f\n') | sh; \
	fi
endef

# Patch <config> <dir>
define Patch
	$(call PatchOne,$(2)/base)
	$(foreach package,$(notdir $(wildcard $(2)/*)),\
		$(if $(findstring CONFIG_PACKAGE_$(package)=y,$(1)),\
			$(call PatchOne,$(2)/$(package)))
	)
endef

# Build <config>
define Build
	$(call Configure,$(1))
	$(MAKE) MAKEOVERRIDES='' -C $(OPENWRT_DIR) V=$(V)
endef

# ImageName <img>
ImageName = $(subst openwrt,carrierwrt-$(VERSION),$(notdir $(1)))

# InstallImage <img> <dir>
define InstallImage
	cp $(1) $(2)/$(call ImageName,$(1))
	cd $(2) && md5sum $(call ImageName,$(1)) > $(call ImageName,$(1)).md5
endef

# Install <images> <tested>
define Install
	mkdir -p firmware/$(PRODUCT)/$(FWSUBDIR)
	mkdir -p firmware/$(PRODUCT)/$(FWSUBDIR)/untested
	$(foreach image,$(1), \
		$(call InstallImage, \
			$(OPENWRT_DIR)/bin/$(image), \
			firmware/$(PRODUCT)/$(FWSUBDIR)$(if \
				$(findstring $(image),$(2)),,/untested))
	) 
endef

# ======================================================================
#  User targets
# ======================================================================

all: $(OPENWRT_DIR) $(OPENWRT_DIR)/feeds.conf
	$(MAKE) _check
	$(MAKE) _build
	$(MAKE) _info

help:
	@echo "============================================================="
	@echo "VARIABLES:"
	@echo "    PRODUCT        Product profile (unset to build all)"
	@echo "    TARGET         Target platform (unset to build all)"
	@echo "    CUSTOMIZATION  Product variant (unset to build all)"
	@echo ""
	@echo "FILES:"
	@echo "    config.mk        Common configuration options"
	@echo "    common/targets/* Target platform configurations"
	@echo "    products/*       Product profile configurations"
	@echo ""
	@echo "EXAMPLES:"
	@echo "    make"
	@echo "    make PRODUCT=rgw TARGET=ar71xx"
	@echo "============================================================="

# ======================================================================
#  Internal targets
# ======================================================================

_check:
	@if ! svn info $(OPENWRT_DIR) | grep -q "Revision: $(CONFIG_OPENWRT_REV)"; then \
		echo "WARNING: Up/downgrading openwrt. Dependency tracking may not work!"; \
		svn update -r $(CONFIG_OPENWRT_REV) $(OPENWRT_DIR); \
	fi
	@svn info $(OPENWRT_DIR)/feeds/luci     | grep -q "Revision: $(CONFIG_LUCI_REV)"
	@svn info $(OPENWRT_DIR)/feeds/packages | grep -q "Revision: $(CONFIG_PACKAGES_REV)"

_info:
	@echo "==============================================================="
	@echo " VERSION:        $(VERSION)"
	@if [ -z "$(PRODUCT)" ]; \
	    then echo " PRODUCTS:       $(PRODUCTS)"; \
	    else echo " PRODUCT:        $(PRODUCT)"; \
	fi
	@if [ -z "$(TARGET)" ]; \
	    then echo " TARGET:         (all)"; \
	    else echo " TARGET:         $(TARGET)"; \
	fi
	@if [ -z "$(CUSTOMIZATION)" ]; \
	    then echo " CUSTOMIZATION:  (all)"; \
	    else echo " CUSTOMIZATION:  $(CUSTOMIZATION)"; \
	fi
	@echo " Firmware images are in $(PWD)/firmware/"
	@echo "==============================================================="

PRODUCTS=$(notdir $(wildcard products/*))
ifeq ($(PRODUCT),)
_build: _build-products
else
include products/$(PRODUCT)/Makefile

TARGETS=$(notdir $(wildcard products/$(PRODUCT)/targets/*))
ifeq ($(TARGET),)
_build: _build-targets
else
include products/$(PRODUCT)/targets/$(TARGET)/Makefile

CUSTOMIZATIONS=$(subst Customization/,,$(filter-out %/prebuild,$(filter Customization/%,$(.VARIABLES))))
ifeq ($(CUSTOMIZATION),)
_build: _build-customizations
else 
_build: _build-images
endif
endif
endif


_build-products:
	$(foreach product,$(PRODUCTS),\
	  $(MAKE) _build-targets PRODUCT=$(product) &&) true

_build-targets:
	$(foreach target,$(TARGETS),\
	  $(MAKE) _build-customizations TARGET=$(target) &&) true

_build-customizations:
	$(foreach customization,$(CUSTOMIZATIONS),\
	  $(MAKE) _build-images CUSTOMIZATION=$(customization) &&) true

_build-images:

	# Revert openwrt and feeds to pristine condition
	scripts/svn-pristine $(OPENWRT_DIR) | sh
	for feed in $(OPENWRT_DIR)/feeds/*; do \
		if [ -d $$feed/.svn ]; then \
			 scripts/svn-pristine $$feed | sh; \
		fi \
	done

	# The special 'files' dir is in svn:ignore so we need to manually delete it
	rm -rf $(OPENWRT_DIR)/files/*

	# Install packages
	$(call InstallPackages)

	# Load Product
	$(eval $(Product/$(PRODUCT)))

	# Load Target
	$(eval $(Target/$(TARGET)))

	# Load Customization
	$(eval $(Customization/$(CUSTOMIZATION)))

	# HACK - Lock LuCI to specific revision
	sed -i 's|^PKG_BRANCH\:=.*|PKG_BRANCH\:=$(CONFIG_LUCI_PATH)@$(CONFIG_LUCI_REV)|' \
			$(OPENWRT_DIR)/feeds/luci/luci/Makefile

	# Write version information
	mkdir -p $(OPENWRT_DIR)/files/etc/
	echo $(VERSION)       > $(OPENWRT_DIR)/files/etc/carrierwrt_version
	echo $(OPENWRT_URL)   > $(OPENWRT_DIR)/files/etc/carrierwrt_openwrt_url
	echo $(PRODUCT)       > $(OPENWRT_DIR)/files/etc/carrierwrt_product
	echo $(CUSTOMIZATION) > $(OPENWRT_DIR)/files/etc/carrierwrt_customization
	
	# Apply product changes
	-cp -rL products/$(PRODUCT)/files/* $(OPENWRT_DIR)/files/

	# Apply target changes
	-cp -rL products/$(PRODUCT)/targets/$(TARGET)/files/* $(OPENWRT_DIR)/files/

	# Apply base patches
	$(call Patch,$(CONFIG),patches)

	# Apply product patches
	$(call Patch,$(CONFIG),products/$(PRODUCT)/patches)

	# Apply target patches
	$(call Patch,$(CONFIG),common/targets/$(TARGET)/patches)

	# Clean old images
	$(call Clean,$(IMAGES))

	# Customization prebuild
	$(Customization/$(CUSTOMIZATION)/prebuild)

	# Build
	$(call Build,$(CONFIG))

	# Install
	$(call Install,$(IMAGES),$(TESTED))

$(OPENWRT_DIR):
	svn co $(OPENWRT_URL) $@

$(OPENWRT_DIR)/feeds.conf: config.mk
	# NOTE: OpenWrt "feeds install" will resolve package dependencies and
	#       install other packages as well. To make sure those dependencies
	#       are primarily resolved against CarrierWrt packages we need to
	#       install them here.
	$(call InstallPackages)

	# BUG: OpenWrt "feeds update" will update to latest revisions
	#      (regardless of @ in URL). As a workaround we do a "feeds clean".
	$(OPENWRT_DIR)/scripts/feeds clean

	echo "src-svn luci $(LUCI_URL)" > $@
	echo "src-svn packages $(PACKAGES_URL)" >> $@
	$(OPENWRT_DIR)/scripts/feeds update
	$(OPENWRT_DIR)/scripts/feeds uninstall -a
	$(OPENWRT_DIR)/scripts/feeds install $(CONFIG_LUCI_LIST)
	$(OPENWRT_DIR)/scripts/feeds install $(CONFIG_PACKAGES_LIST)

.PHONY: all help _check _info _build _build-products _build-targets _build-images
