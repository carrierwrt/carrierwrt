include $(TOPDIR)/rules.mk

PKG_NAME    := factory-defaults
PKG_VERSION := 1.1
PKG_RELEASE := 1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION  := base
  CATEGORY := Base system
  TITLE    := Persistent factory default settings
  URL      := 
endef

define Package/$(PKG_NAME)/description
  Scripts that add support for factory default settings persistently stored in overlay.
endef

define Build/Compile

endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR)  $(1)/lib/upgrade
	$(INSTALL_DATA) ./files/lib/upgrade/factory-defaults.sh \
			$(1)/lib/upgrade/factory-defaults.sh
	$(INSTALL_DIR)  $(1)/lib/firstboot
	$(INSTALL_DATA) ./files/lib/firstboot/10_save_factory_defaults \
			$(1)/lib/firstboot/10_save_factory_defaults
	$(INSTALL_DATA) ./files/lib/firstboot/99_10_restore_factory_defaults \
			$(1)/lib/firstboot/99_10_restore_factory_defaults
	$(INSTALL_DIR)  $(1)/etc/hotplug.d/button
	$(INSTALL_DATA) ./files/etc/hotplug.d/button/99-reset-to-factory-defaults \
			$(1)/etc/hotplug.d/button/99-reset-to-factory-defaults
	# The two directories that will be saved/persisted:
	$(INSTALL_DIR)  $(1)/etc/factory-defaults/persist
	$(INSTALL_DIR)  $(1)/etc/factory-defaults/save
	# The uci-defaults script that will apply setup/migrations:
	$(INSTALL_DIR)  $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/z00-factory-defaults \
			$(1)/etc/uci-defaults/z00-factory-defaults
endef

$(eval $(call BuildPackage,$(PKG_NAME),))
