
[CarrierWrt](http://carrierwrt.org)
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
fork CarrierWrt! It embodies wisdom from years of experience developing
commercial products based on OpenWrt, and will serve as an excellent starting
point for yours.

## Firmware Images

Pre-built firmware images are available at http://carrierwrt.org/download.
Directories correspond to git tags, with [latest](http://carrierwrt.org/download/latest)
and [stable](http://carrierwrt.org/download/stable) symlinks for convenience.

## Functionality

CarrierWrt comes with some additional functionality not found in (standard
builds of) OpenWrt.

### Management

[EasyCwmp](http://github.com/carrierwrt/easycwmp) is a (rudimentary) open source
implementation of
[TR-069 CPE WAN Management Protocol (CWMP)](http://en.wikipedia.org/wiki/TR-069)
pre-integrated in `rgw` and `ap` CarrierWrt product variants. ACS discovery
through DHCP Option 43 is supported. Interoperability with
[GenieACS](http://github.com/carrierwrt/genieacs) has been verified.

### Carrier Wi-Fi

CarrierWrt comes with [Anyfi.net](http://anyfi.net) software pre-integrated,
ensuring compatibility with [Anyfi Networks](http://www.anyfinetworks.com)'
Carrier Wi-Fi System. This lets operators build [completely seamless "homespot"
user experiences with end-to-end security](http://www.anyfinetworks.com/solutions#simple).
It also enables seamless integration of equipment running CarrierWrt into
existing carrier Wi-Fi solutions, e.g. for [mobile Wi-Fi offload or traditional
hotspot services](http://www.anyfinetworks.com/solutions#hotspot).

Community Edition of Anyfi Networks' Carrier Wi-Fi System is
[freely available](http://www.anyfinetworks.com/download). This version 
is fully functional, but restricted to a maximum of 100 access point
radios.

## Getting Started

You need to have installed git, svn, gcc, g++, binutils, patch, bzip2, flex,
make, gettext, pkg-config, unzip, libz-dev, libncurses-dev, gawk and libc
headers. For example, on a Debian based system run the command:

```
  apt-get install -y git subversion gcc g++ binutils patch bzip2 flex make \
                     gettext pkg-config unzip libz-dev libncurses-dev gawk \
                     gcc-multilib
```

Then:

1. git clone https://github.com/carrierwrt/carrierwrt.git

2. cd carrierwrt && make

Basic build configuration is in config.mk. Functionality and default settings
are controlled through what we call product profiles and customizations (in
`products/*/Makefile`).

Next step is to fork this repository and get started making changes!

## Copyright and Licensing

The CarrierWrt build system overlay is licensed under a highly permissive
"1-clause BSD license". See the LICENSE file for more details.

The OpenWrt build system, as well as the software built by the build system, is
licensed separately under their own licenses.

