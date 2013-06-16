include $(TOPDIR)/rules.mk

PKG_NAME    := luci-branding
PKG_VERSION := 1.0
PKG_RELEASE := 1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION  := base
  CATEGORY := Base system
  TITLE    := Web UI branding
  URL      :=
endef

define Package/$(PKG_NAME)/description
  LuCI web UI branding for CarrierWrt
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME),))
