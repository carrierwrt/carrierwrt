include $(TOPDIR)/rules.mk

ANYFI_TARGET := $(ARCH)-linux-$(subst C,c,$(LIBC))-$(LIBCV)

PKG_NAME    := anyfi-mac
PKG_VERSION := 1.5.3
PKG_RELEASE := 1

PKG_SOURCE     := anyfimac-$(PKG_VERSION)-$(ANYFI_TARGET).tar.bz2
PKG_SOURCE_URL := http://anyfi.net/download
PKG_BUILD_DIR  := $(BUILD_DIR)/anyfimac-$(PKG_VERSION)-$(ANYFI_TARGET)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION    := net
  CATEGORY   := Network
  TITLE      := Anyfi.net - Free SDWN Data Plane for IEEE 802.11
  URL        := http://anyfi.net
  DEPENDS    := +kmod-tun +librt
  MENU       := 1
  MAINTAINER := Anyfi Networks <eng@anyfinetworks.com>
endef

define Package/$(PKG_NAME)/description
	Anyfi.net is a free Software-Defined Wirless Networking (SDWN)
	forwarding data plane implementation for IEEE 802.11.
endef

define Build/Compile
	@echo "Nothing to do - Anyfi.net software comes pre-built."
endef

define Package/$(PKG_NAME)/conffiles
	/etc/config/anyfi
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/anyfimac $(1)/sbin
	$(LN) anyfimac $(1)/sbin/anyfid
	$(LN) anyfimac $(1)/sbin/myfid
	$(INSTALL_DIR) $(1)/bin
	$(LN) ../sbin/anyfimac $(1)/bin/anyfidctl
	$(LN) ../sbin/anyfimac $(1)/bin/myfidctl
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
