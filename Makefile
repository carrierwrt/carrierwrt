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
LUCI_BASE    	:= http://svn.luci.subsignal.org/luci
LUCI_URL     	:= $(LUCI_BASE)/$(CONFIG_LUCI_PATH)/contrib/package@$(CONFIG_LUCI_REV)
LUCI_FEEDS_DIR  := $(OPENWRT_DIR)/feeds/luci
PACKAGES        := $(wildcard package/*)

# Reset variables
define ResetVariables
	SETTINGS =
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
	rm -f firmware/$(PRODUCT)/$(TARGET)/$(CUSTOMIZATION)/$(notdir $(1))*
endef

# Clean <images>
define Clean
	$(foreach image,$(1),$(call CleanImage,$(image)) &&) true
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
	$(foreach package,$(notdir $(wildcard $(2)/*)),\
		$(if $(findstring CONFIG_PACKAGE_$(package)=y,$(1)),\
			$(call PatchOne,$(2)/$(package))))
endef

# Build <images> <config>
define Build
	$(call Configure,$(2))
	$(call Clean,$(1))
	$(MAKE) MAKEOVERRIDES='' -C $(OPENWRT_DIR) V=$(V)
	$(call Install,$(1))
endef

# InstallImage <image>
define InstallImage
	cp $(OPENWRT_DIR)/bin/$(1) firmware/$(PRODUCT)/$(TARGET)/$(CUSTOMIZATION)/$(notdir $(1))
	md5sum firmware/$(PRODUCT)/$(TARGET)/$(CUSTOMIZATION)/$(notdir $(1)) \
		> firmware/$(PRODUCT)/$(TARGET)/$(CUSTOMIZATION)/$(notdir $(1)).md5
endef

# Install <images>
define Install
	mkdir -p firmware/$(PRODUCT)/$(TARGET)/$(CUSTOMIZATION)
	$(foreach image,$(1),$(call InstallImage,$(image)) &&) true
endef

# ======================================================================
#  User targets
# ======================================================================

all: $(OPENWRT_DIR) $(OPENWRT_DIR)/feeds.conf
	$(MAKE) _touch
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

_info:
	@echo "==============================================================="
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

_touch:
	$(foreach package,$(PACKAGES),$(shell touch $(package)/Makefile))

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

CUSTOMIZATIONS=$(notdir $(wildcard products/$(PRODUCT)/customizations/*))
ifeq ($(CUSTOMIZATION),)
_build: _build-customizations
else 
include products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/Makefile

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
	$(MAKE) _build-images
	$(foreach customization,$(CUSTOMIZATIONS),\
	   $(MAKE) _build-images CUSTOMIZATION=$(customization) &&) true

_build-images:

	# Revert openwrt and luci to pristine condition
	scripts/svn-pristine $(OPENWRT_DIR) | sh
	scripts/svn-pristine $(LUCI_FEEDS_DIR) | sh

	$(foreach package,$(PACKAGES),ln -fs ../../$(package) $(OPENWRT_DIR)/$(package))
	mkdir -p $(OPENWRT_DIR)/files/etc/uci-defaults

	# Load Product
	$(eval $(ResetVariables))
	$(eval $(Product/$(PRODUCT)))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z01-product || break; \
	fi

	# Load Target
	$(eval $(ResetVariables))
	$(eval $(Target/$(TARGET)))
	if [ -n "$(SETTINGS)" ]; then \
		cp common/targets/$(TARGET)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z02-target || break; \
	fi

	# Load Customization
	$(eval $(ResetVariables))
ifneq ($(CUSTOMIZATION),)
	$(eval $(Customization/$(CUSTOMIZATION)))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/$(SETTINGS) \
			$(OPENWRT_DIR)/files/etc/uci-defaults/z03-customization || break; \
	fi
else
	$(eval $(Customization/default))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z03-customization || break; \
	fi
endif


	# Lock LuCI to specific revision
	sed -i 's|^PKG_BRANCH\:=.*|PKG_BRANCH\:=$(CONFIG_LUCI_PATH)@$(CONFIG_LUCI_REV)|' \
               $(LUCI_FEEDS_DIR)/luci/Makefile
	
	# Apply product changes
	-cp -r products/$(PRODUCT)/files/* $(OPENWRT_DIR)/files/

	# Apply target changes
	-cp -r products/$(PRODUCT)/targets/$(TARGET)/files/* $(OPENWRT_DIR)/files/

ifneq ($(CUSTOMIZATION),)
	# Apply customizations
	-cp -r products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/files/* $(OPENWRT_DIR)/files/
endif

	# Apply base patches
	$(call Patch,$(CONFIG),patches)

	# Apply product patches
	$(call Patch,$(CONFIG),products/$(PRODUCT)/patches)

	# Apply target patches
	$(call Patch, $(CONFIG),common/targets/$(TARGET)/patches)

ifneq ($(CUSTOMIZATION),)
	# Apply customization patches
	$(call Patch,$(CONFIG),products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/patches)
endif
	
	# Build
	$(call Build,$(IMAGES),$(CONFIG))


$(OPENWRT_DIR):
	svn co $(OPENWRT_URL) $@

$(OPENWRT_DIR)/feeds.conf:
	echo "src-svn packages svn://svn.openwrt.org/openwrt/packages" > $@
	echo "src-svn luci $(LUCI_URL)" >> $@
	$(OPENWRT_DIR)/scripts/feeds update
	$(OPENWRT_DIR)/scripts/feeds install luci

.PHONY: all help _info _touch _build _build-products _build-targets _build-images
