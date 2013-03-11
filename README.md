
CarrierWrt
==========

CarrierWrt is an OpenWrt overlay that simplifies development of commercial
products by focusing on aspects that are important to equipment vendors and
their customers:

* CarrierWrt's build configuration is versioned, i.e. there is no "menuconfig"
  build target. If you build from the same source you will (or should) end up
  with the same firmware.

* CarrierWrt is designed to produce complete firmware that can be put through
  QA and is usable out of the box. While it is possible to postinstall packages
  the end-user should not have to. In a sense you can think of CarrierWrt as
  the cathedral built on top of OpenWrt, the bazar.

* OpenWrt traditionally stays very close to the bleeding edge of open source,
  even on the release branches (e.g. backfire). CarrierWrt is much more
  conservatively maintained. We try to fix bugs with minimal patches instead of
  updating to the latest snapshots.

* Proprietary closed source software is usually not welcomed into open source
  respositories with open arms. Nevertheless equipment vendors often need to
  add some bells and whistles to differentiate their products. CarrierWrt is
  designed to make it easy to integrate proprietary software, and even comes
  with some functionality essential to carrier customers pre-integrated.

In short, if you want to build a commercial product based on OpenWrt you should
clone CarrierWrt! It embodies wisdom from years of experience with "branching
OpenWrt" and developing commercial products, and will serve as an excellent
starting point for yours.

How to get started
==================

You need to have installed git, svn, gcc, binutils, patch, bzip2, flex, make,
gettext, pkg-config, unzip, libz-dev, libncurses-dev, gawk and libc headers.
Then:

1. git clone https://github.com/carrierwrt/carrierwrt.git

2. cd carrierwrt && make

Basic build configuration in config.mk. Functionality and default settings are
controlled through what we call "product profiles" in products/*.mk. Target
specific build configurations are in targets/*.mk.

Next step is to clone this repository and get started making changes!

Copyright and licensing
=======================

The CarrierWrt build system overlay is licensed under a highly permissive "1-clause
BSD license". See the LICENSE file for more details.

The OpenWrt build system, as well as the software built by the build system, is
licensed separately under their own licenses.
