#
# Copyright (C) 2013 CarrierWrt.org
#

include config.mk

# Products
PRODUCTS=$(notdir $(wildcard products/*))
$(foreach product, $(PRODUCTS), $(eval include products/$(product)/Makefile))

# ======================================================================
#  Internal variables
# ======================================================================

V ?= 0
J ?= 3

OPENWRT_BASE 	:= svn://svn.openwrt.org/openwrt
OPENWRT_DIR  	:= openwrt
OPENWRT_URL  	:= $(OPENWRT_BASE)/$(CONFIG_OPENWRT_PATH)@$(CONFIG_OPENWRT_REV)
LUCI_BASE    	:= http://svn.luci.subsignal.org/luci
LUCI_URL     	:= $(LUCI_BASE)/$(CONFIG_LUCI_PATH)/contrib/package@$(CONFIG_LUCI_REV)
LUCI_FEEDS_DIR	:= $(OPENWRT_DIR)/feeds/luci/luci

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
	$(MAKE) -C $(OPENWRT_DIR) defconfig > /dev/null
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

# Build <images> <config>
define Build
	$(call Configure,$(2))
	$(call Clean,$(1))
	make -j $J -C $(OPENWRT_DIR) V=$(V)
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

# NotSupported <product> <target>
define NotSupported
	@echo "============================================================="
	@echo "SORRY, PRODUCT PROFILE $(1) CANNOT BE BUILT FOR TARGET $(2)."
	@echo "============================================================="
endef

# ======================================================================
#  User targets
# ======================================================================

all: $(OPENWRT_DIR) $(OPENWRT_DIR)/feeds.conf
	$(MAKE) .prepare
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
	@if [ -z "$(TARGET)" ]; \
	    then echo " TARGET:  (all)"; \
	    else echo " TARGET:  $(TARGET)"; \
	fi
	@echo " Firmware images are in $(PWD)/firmware/"
	@echo "==============================================================="

_touch:
	#touch -f package/*/Makefile

ifeq ($(PRODUCT),)
_build: _build-products
else

# Load all targets:
TARGETS=$(notdir $(wildcard products/$(PRODUCT)/targets/*))
$(foreach target, $(TARGETS), \
	$(eval include products/$(PRODUCT)/targets/$(target)/Makefile))

# Load all customizations:
CUSTOMIZATIONS=$(notdir $(wildcard products/$(PRODUCT)/customizations/*))
$(foreach customization, $(CUSTOMIZATIONS), \
	$(eval include products/$(PRODUCT)/customizations/$(customization)/Makefile))

ifeq ($(TARGET),)
_build: _build-targets
else
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
	$(MAKE) _build-images
	$(foreach customization,$(CUSTOMIZATIONS),\
	   $(MAKE) _build-images CUSTOMIZATION=$(customization) &&) true

_build-images:

	# Clear/prepare openwrt/files directory
	test -d $(OPENWRT_DIR)/files/etc/uci-defaults && rm -rf $(OPENWRT_DIR)/files/etc/uci-defaults/* || mkdir -p $(OPENWRT_DIR)/files/etc/uci-defaults

	# Load Product
	$(eval $(call ResetVariables))
	$(eval $(call Product/$(PRODUCT)))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z01-product || break; \
	fi

	# Load Target
	$(eval $(call ResetVariables))
	$(eval $(call Target/$(TARGET)))
	if [ -n "$(SETTINGS)" ]; then \
		cp common/targets/$(TARGET)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z02-target || break; \
	fi

	# Load Customization
	$(eval $(call ResetVariables))
ifneq ($(CUSTOMIZATION),)
	$(eval $(call Customization/$(CUSTOMIZATION)))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z03-customization || break; \
	fi
else
	$(eval $(call Customization/default))
	if [ -n "$(SETTINGS)" ]; then \
		cp products/$(PRODUCT)/$(SETTINGS) $(OPENWRT_DIR)/files/etc/uci-defaults/z03-customization || break; \
	fi
endif


	# Lock LuCI to specific revision
	sed -i 's/^PKG_BRANCH\:=.*/PKG_BRANCH\:=$(CONFIG_LUCI_PATH)@$(CONFIG_LUCI_REV)/' \
               $(LUCI_FEEDS_DIR)/Makefile
	
	# Apply product changes
	-cp -r products/$(PRODUCT)/files/* $(OPENWRT_DIR)/files/

	# Apply target changes
	-cp -r products/$(PRODUCT)/targets/$(TARGET)/files/* $(OPENWRT_DIR)/files/

ifneq ($(CUSTOMIZATION),)
	# Apply customizations
	-cp -r products/$(PRODUCT)/customizations/$(CUSTOMIZATION)/files/* $(OPENWRT_DIR)/files/
endif
	
	# Build
	$(if $(findstring $(TARGET),$(TARGETS)),\
		$(call Build,$(IMAGES),$(CONFIG)),\
		$(call NotSupported,$(PRODUCT),$(TARGET)))

.prepare:
	#(cd $(OPENWRT_DIR)/package && ln -fs ../../package/*/ .)
	#(cd patches && \
	# find package feeds -name '*.patch' \
	#   -printf 'mkdir -p ../$(OPENWRT_DIR)/%h/patches && cp %p ../$(OPENWRT_DIR)/%h/patches/%f\n' | sh)
	#for f in patches/openwrt/*; do \
	#    (cd $(OPENWRT_DIR) && ls ../$$f); \
	#    (cd $(OPENWRT_DIR) && patch -N -p0 < ../$$f); \
	#done
	touch $@

$(OPENWRT_DIR):
	svn co $(OPENWRT_URL) $@

$(OPENWRT_DIR)/feeds.conf:
	echo "src-svn packages svn://svn.openwrt.org/openwrt/packages" > $@
	echo "src-svn luci $(LUCI_URL)" >> $@
	$(OPENWRT_DIR)/scripts/feeds update
	$(OPENWRT_DIR)/scripts/feeds install luci

.PHONY: all help _info _touch _build _build-products _build-targets _build-images
