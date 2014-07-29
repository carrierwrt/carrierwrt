#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=easycwmp
PKG_VERSION:=1.0.1
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=7f75e85c1dc6dce3a6ec1101e72010a075909e70
PKG_SOURCE_URL:=https://github.com/carrierwrt/easycwmp.git

PKG_SOURCE:=easycwmp-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_FIXUP:=autoreconf

PKG_CONFIG_DEPENDS:= \
	CONFIG_EASYCWMP_ACS_MULTI \
	CONFIG_EASYCWMP_ACS_HDM \
	CONFIG_EASYCWMP_DEBUG \
	CONFIG_EASYCWMP_DEVEL

include $(INCLUDE_DIR)/package.mk

define Package/easycwmp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CWMP client (using libcurl)
  DEPENDS:=+libubus +libuci +libubox +libmicroxml \
           +libjson-c +shflags +libcurl +@LIBCURL_COOKIES \
           +@BUSYBOX_CONFIG_BASE64
endef

define Package/easycwmp/description
 An open source implementation of the client CWMP (TR-069) protocol
endef

define Package/easycwmp/config
	source "$(SOURCE)/Config.in"
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include


ifeq ($(CONFIG_EASYCWMP_ACS_MULTI),y)
CONFIGURE_ARGS += \
	--enable-acs=multi
endif

ifeq ($(CONFIG_EASYCWMP_ACS_HDM),y)
CONFIGURE_ARGS += \
	--enable-acs=hdm
endif

ifeq ($(CONFIG_EASYCWMP_DEBUG),y)
CONFIGURE_ARGS += \
	--enable-debug
endif

ifeq ($(CONFIG_EASYCWMP_DEVEL),y)
CONFIGURE_ARGS += \
	--enable-devel
endif

CONFIGURE_ARGS += \
	--enable-jsonc=1

define Package/easycwmp/conffiles
/etc/config/easycwmp
/usr/share/easycwmp/defaults
endef

define Package/easycwmp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/easycwmpd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/ext/openwrt/config/easycwmp $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ext/openwrt/init.d/easycwmpd $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/easycwmp
ifeq ($(CONFIG_EASYCWMP_SCRIPTS_FULL),y)
	$(INSTALL_DIR) $(1)/usr/share/easycwmp
	$(CP) $(PKG_BUILD_DIR)/ext/openwrt/scripts/defaults $(1)/usr/share/easycwmp
	$(CP) $(PKG_BUILD_DIR)/ext/openwrt/scripts/functions $(1)/usr/share/easycwmp
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ext/openwrt/scripts/easycwmp.sh $(1)/usr/sbin/easycwmp
	$(CP) ./files/* $(1)/
endif
endef

$(eval $(call BuildPackage,easycwmp))
