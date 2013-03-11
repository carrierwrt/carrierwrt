#
# Copyright (C) 2013 CarrierWrt.org
#

include config.mk

include products/rgw.mk

include targets/ar71xx.mk

# ======================================================================
#  Internal variables
# ======================================================================

V ?= 0

OPENWRT_BASE := svn://svn.openwrt.org/openwrt
OPENWRT_DIR  := openwrt
OPENWRT_URL  := $(OPENWRT_BASE)/$(CONFIG_OPENWRT_REV)
LUCI_BASE    := http://svn.luci.subsignal.org/luci
LUCI_URL     := $(LUCI_BASE)/$(CONFIG_LUCI_REV)

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

# CleanImage <target> <image>
define CleanImage
	rm -f $(OPENWRT_DIR)/bin/$(3)
	rm -f firmware/$(1)/$(2)/$(notdir $(3))*
endef

# Clean <product> <target> <images>
define Clean
	$(foreach image,$(3),$(call CleanImage,$(1),$(2),$(image)) &&) true
endef

# Build <product> <target> <images> <config>
define Build
	$(call Configure,$(4))
	$(call Clean,$(1),$(2),$(3))
	make -j -C $(OPENWRT_DIR) V=$(V)
	$(call Install,$(1),$(2),$(3))
endef

# InstallImage <target> <image>
define InstallImage
	cp $(OPENWRT_DIR)/bin/$(3) firmware/$(1)/$(2)/$(notdir $(3))
	md5sum firmware/$(1)/$(2)/$(notdir $(3)) > firmware/$(1)/$(2)/$(notdir $(3)).md5
endef

# Install <product> <target> <images>
define Install
	mkdir -p firmware/$(1)/$(2)
	$(foreach image,$(3),$(call InstallImage,$(1),$(2),$(image)) &&) true
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
	@echo "    PRODUCT   Product product (unset to build all)"
	@echo "    TARGET    Target platform name (unset to build all)"
	@echo ""
	@echo "FILES:"
	@echo "    config.mk       Common configuration options"
	@echo "    products/*.mk   Product product configurations"
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
ifeq ($(TARGET),)
_build: _build-targets
else
_build: _build-images
endif
endif

_build-products:
	$(foreach product,$(ALL_PRODUCTS),\
	   $(MAKE) _build-targets PRODUCT=$(product) &&) true

_build-targets:
	$(foreach target,$(ALL_TARGETS),\
	   $(MAKE) _build-images TARGET=$(target) &&) true

_build-images:
	$(eval $(call Target/$(TARGET)))
	$(eval $(call Product/$(PRODUCT)))
	$(if $(findstring $(TARGET),$(SUPPORTED_TARGETS)),\
		$(call Build,$(PRODUCT),$(TARGET),$(IMAGES),$(CONFIG)),\
		$(call NotSupported,$(PRODUCT),$(TARGET)))

.prepare:
	-(cd $(OPENWRT_DIR)/package && ln -fs ../../package/*/ .)
	-(cd patches && \
	 find package feeds -name '*.patch' \
	   -printf 'mkdir -p ../$(OPENWRT_DIR)/%h/patches && cp %p ../$(OPENWRT_DIR)/%h/patches/%f\n' | sh)
	-for f in patches/openwrt/*; do \
	    (cd $(OPENWRT_DIR) && ls ../$$f); \
	    (cd $(OPENWRT_DIR) && patch -N -p0 < ../$$f); \
	done
	touch $@

$(OPENWRT_DIR):
	svn co $(OPENWRT_URL) $@

$(OPENWRT_DIR)/feeds.conf:
	echo "src-svn packages svn://svn.openwrt.org/openwrt/packages" > $@
	echo "src-svn luci $(LUCI_URL)" >> $@
	$(OPENWRT_DIR)/scripts/feeds update
	$(OPENWRT_DIR)/scripts/feeds install luci

.PHONY: all help _info _touch _build _build-products _build-targets _build-images
