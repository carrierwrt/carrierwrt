include $(TOPDIR)/rules.mk

PKG_NAME    := system-debug
PKG_VERSION := 1.0
PKG_RELEASE := 1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION  := net
  CATEGORY := Base system
  TITLE    := Debug build settings
endef

define Package/$(PKG_NAME)/description
  System-wide settings for debug builds, e.g. enabling core dumps.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	touch $(1)/.init_enable_core
endef

$(eval $(call BuildPackage,$(PKG_NAME),))
