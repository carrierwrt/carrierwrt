include $(TOPDIR)/rules.mk

PKG_NAME    := watchdog
PKG_VERSION := 1.0
PKG_RELEASE := 1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION  := base
  CATEGORY := Base system
  TITLE    := A better watchdog
  URL      := 
endef

define Package/$(PKG_NAME)/description
  A simple replacement for the BusyBox watchdog, supporting shell script "plugins"
  for monitoring system health.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME),))
