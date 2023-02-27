---
slug: building-old-software-on-armel-on-linux-x64-amd64
aliases:
- /2019/11/25/building-old-software-on-armel-on-linux-x64-amd64/
- /post/building-old-software-on-armel-on-linux-x64-amd64/
- /building-old-software-on-armel-on-linux-x64-amd64/
- /docs/arm-development/cross-build/building-old-software-on-armel-on-linux-x64-amd64/
- /develop-design/arm-development/cross-build/building-old-software-on-armel-on-linux-x64-amd64/
- /devel/build-old-software-on-armel-on-linux-x64-amd64/
- /docs/devel/arm-devel/building-old-software-on-armel-on-linux-x64-amd64/
author: Daniel F. Dickinson
tags:
    - arm-devel
    - armel
    - armhf
    - cross-compile
    - devel
    - docs
    - firmware
    - linux
    - virtualization
date: '2019-11-25T10:27:00+00:00'
publishDate: '2019-11-25T10:27:00+00:00'
title: Building for armel on Linux x64 using Docker
description: "Setting up a virtual ARM environment for doing armel (ARMv5) compilation using docker containers."
summary: "The cross-compilation toolchains builtin to most modern Linux distributions do not support older versions of GCC. This article describes setting up a virtual ARM environment for doing armel (ARMv5) compilation using docker containers"
weight: 9800
series:
    - debian-on-a-craig-clp281
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Overview

The cross-compilation toolchains builtin to most modern Linux distributions do not support older versions of GCC. For old kernels (and other software) that require GCC4 or lower for building, this poses a challenge. One either needs to build a cross-compilation toolchain or use virtualization.  This article describes setting up a virtual ARM environment for doing armel (ARMv5) compilation using docker containers.

On Debian Buster and versions of Ubuntu based on the same vintage qemu-user, this technique is not useful due to a bug: <https://bugs.launchpad.net/qemu/+bug/1805913>.

Even without this bug, a better technique is to use build a virtual machine and to run whatever scripts or builds one wants in the VM, as described in [Cross-Compile for Armel Using an ARM HF VM](2021-02-13-cross-compile-for-armel-using-an-arm-hf-vm/).

Nonetheless if you still want to try the (slower) Docker technique, it is described below.

## Preliminaries

* We’re going to use Debian’s armel port for this exercise.
* We’re using Debian Jessie for GCC4 support. If you need older GCC, then you need an appropriate OS, or to build a cross-compilation toolchain.
* The instructions are written assuming we are running on a Debian system. However, debootstrap is also available for use on non-Debian systems as is an up-to-date docker.io.
* You need debootstrap and docker on your system (apt-get install debootstrap docker.io)
* If you have access to a prebuilt Debian armel rootfs you can skip directly to creating the container.
* This article assumes you have Docker configured and running

## Create the Rootfs

Use the [script to create a Debian Jessie rootfs](#using-a-script) below.

### What the Script Does

#### Create the Base System

1. ``sudo apt-get install qemu-user-static``

   * On Debian 10 this will automatically register ARM EABI binaries
     for execution by qemu-arm-static (userspace emulation of the
     ARM architecture on non-ARM architectures such as x86).
   * For older distributions the registration may not be automatic,
     in which case you need to look up binfmt registration, e.g. see ~~`https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/`~~.

2. ``mkdir -p armel-root/usr/bin``
3. ``cp /usr/bin/qemu-arm-static armel-root/usr/bin/qemu-arm-static``
4. ``sudo debootstrap --arch=armel --foreign jessie "$(pwd)"/armel-root``
5. ``cp /usr/bin/qemu-arm-static armel-root/usr/bin``
6. ``sudo PATH=/bin:/sbin:/usr/bin:/usr/sbin /sbin/chroot armel-root /usr/bin/qemu-arm-static /bin/bash``
7. ``export LANG=C.UTF-8``
8. Depending on what terminal you are using, you may need to also do:
``export TERM=xterm-color``. (This is only required if your
terminal is not supported by a default Debian Jessie install).
9. ``/debootstrap/debootstrap --second-stage``

#### Prepare the Base System for First Boot

Assuming you are still in the chroot:

Follow the rest of the instructions at <https://www.debian.org/releases/jessie/armel/apds03.html.en#idp51134208> (more details below).

1. ``mount -t proc proc /proc``
2. ``apt-get install makedev``
3. ``cd /dev``
4. ``MAKEDEV generic``
5. Create ``/etc/fstab``, for example (for virtualization):

   ```conf
   # /etc/fstab: static file system information.
   #
   # file system mount point type options dump pass
   /dev/sda / ext4 defaults 0 1
   proc /proc proc defaults 0 0
   ```

6. Create /etc/network/interfaces, for example:

   ```conf
   ######################################################################
   # /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)
   # See the interfaces(5) manpage for information on what options are
   # available.
   ######################################################################

   # The loopback interface isn't really required any longer, but can be used
   # if needed.
   #
   auto lo
   iface lo inet loopback

   # To use dhcp:
   #
   auto eth0
   iface eth0 inet dhcp

   # An example static IP setup: (network, broadcast and gateway are optional)
   #
   # auto eth0
   # iface eth0 inet static
   # address 192.168.0.42
   # network 192.168.0.0
   # netmask 255.255.255.0
   # broadcast 192.168.0.255
   # gateway 192.168.0.1

   # Include files from /etc/network/interfaces.d:
   source-directory /etc/network/interfaces.d
   ```

7. ``apt-get install resolvconf``
8. ``echo jessie-armel-build > /etc/hostname``
9. Update ``/etc/apt/sources.list``. For example:

   ```conf
   deb http://deb.debian.org/debian jessie main contrib non-free
   deb-src http://deb.debian.org/debian jessie main contrib non-free
   deb http://deb.debian.org/debian-security jessie/updates main contrib non-free
   deb-src http://deb.debian.org/debian-security jessie/updates main contrib non-free
   deb http://deb.debian.org/debian jessie-updates main contrib non-free
   deb-src http://deb.debian.org/debian jessie-updates main contrib non-free
   ```

10. ``apt-get update && apt-get upgrade``
11. ``apt-get install locales && dpkg-reconfigure locales``
12. ``apt-get install console-setup && dpkg-reconfigure keyboard-configuration``
13. ``apt-get install sudo``
14. ``adduser builder``
15. ``adduser builder sudo``
16. ``tasksel install standard``
17. ``apt-get clean``
18. ``/etc/init.d/exim4 stop``
19. ``/etc/init.d/cron stop``
20. ``/etc/init.d/rsyslog stop``
21. ``/etc/init.d/dbus stop``
22. ``pkill -TERM rsyslogd``
23. ``umount /proc``
24. ``exit``

#### Create a Tarball of the Rootfs

``tar -C armel-root --remove-files --one-file-system -czf jessie-armel-build.tar.gz .``

### Using a Script

**NB**: The script is interactive and you will be prompted at some
points. If you’re looking for complete automation you will need to
modify the script appropriately.

1. Copy the script below to create-jessie-armel-build.sh
2. ``sudo sh -c create-jessie-armel-build.sh``
3. ``sudo chown *yourusername*:*yourusername* jessie-armel-build.tar.gz``

```sh
#!/bin/sh
set -e

apt-get install qemu-user-static
mkdir -p armel-root/root
mkdir -p armel-root/usr/bin
cp /usr/bin/qemu-arm-static armel-root/usr/bin/
debootstrap --arch=armel --foreign jessie "$(pwd)"/armel-root

cat >armel-root/root/prepare-debian-rootfs.sh <<EOF
#!/bin/sh

set -e

export LANG=C.UTF-8
export TERM=xterm-color
/debootstrap/debootstrap --second-stage
mount -t proc proc /proc
cd /dev
apt-get -y install makedev
MAKEDEV generic

cat >/etc/fstab <<FSTABEOF
# /etc/fstab: static file system information.
#
# file system mount point type options dump pass
/dev/sda / ext4 defaults 0 1
proc /proc proc defaults 0 0
FSTABEOF

cat >/etc/network/interfaces <<IFACEEOF
######################################################################
# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)
# See the interfaces(5) manpage for information on what options are
# available.
######################################################################

# The loopback interface is not really required any longer, but can be used
# if needed.
#
auto lo
iface lo inet loopback

# To use dhcp:
#
auto eth0
iface eth0 inet dhcp

# An example static IP setup: (network, broadcast and gateway are optional)
#
# auto eth0
# iface eth0 inet static
# address 192.168.0.42
# network 192.168.0.0
# netmask 255.255.255.0
# broadcast 192.168.0.255
# gateway 192.168.0.1

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
IFACEEOF

apt-get -y install resolvconf
echo jessie-armel-build >/etc/hostname

cat >/etc/apt/sources.list <<SRCEOF
deb http://deb.debian.org/debian jessie main contrib non-free
deb-src http://deb.debian.org/debian jessie main contrib non-free
deb http://deb.debian.org/debian-security jessie/updates main contrib non-free
deb-src http://deb.debian.org/debian-security jessie/updates main contrib non-free
deb http://deb.debian.org/debian jessie-updates main contrib non-free
deb-src http://deb.debian.org/debian jessie-updates main contrib non-free
SRCEOF

apt-get update && apt-get -y upgrade
apt-get -y install locales && dpkg-reconfigure locales
apt-get -y install console-setup && dpkg-reconfigure keyboard-configuration
apt-get -y install sudo
adduser builder
adduser builder sudo
tasksel install standard
apt-get clean
/etc/init.d/exim4 stop || true
/etc/init.d/atd stop || true
/etc/init.d/rsyslog stop || true
/etc/init.d/cron stop || true
/etc/init.d/dbus stop || true
sleep 2
pkill -TERM rsyslogd || true
sleep 2
/etc/init.d/cron stop || true
sleep 2
umount /proc
EOF

chmod 755 armel-root/root/prepare-debian-rootfs.sh
cp /usr/bin/qemu-arm-static armel-root/usr/bin
PATH=/bin:/sbin:/usr/bin:/usr/sbin /sbin/chroot armel-root /usr/bin/qemu-arm-static /bin/bash -c /root/prepare-debian-rootfs.sh || {
echo "Failed to chroot; cant create rootfs!"
exit 1
}
echo "Created rootfs; creating tarball from rootfs"

tar -C armel-root --remove-files --one-file-system -czf jessie-armel-build.tar.gz .

rm -rf armel-root

echo "Done. Created tarball of rootfs."
```

## Create the Docker Image

### Create the Base Image

``cat jessie-armel-build.tar.gz | docker import - jessie-armel:latest``

### Build the Development Environment Container

1. Create a directory (e.g. mkdir workdir) and change to it (e.g.
cd workdir).
2. Create a file called Dockerfile such as:

   ```Dockerfile
   FROM jessie-armel:latest

   RUN apt-get update && \
   apt-get -y upgrade && \
   apt-get install -y \
   bash-completion \
   binutils-dev \
   build-essential \
   bzip2 \
   cmake \
   curl \
   debhelper \
   dh-systemd \
   dpkg-dev \
   diffutils \
   fakeroot \
   fakechroot \
   git \
   gnupg2 \
   libbfb0-dev \
   libc6-dev \
   libcurl4-gnutls-dev \
   libdw-dev \
   libelf-dev \
   ncurses-dev \
   pkg-config \
   python-minimal \
   quilt \
   u-boot-tools \
   wget \
   xmlto \
   xz-utils \
   zlib1g-dev

   RUN apt-get -y build-dep linux-source && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*

   RUN mkdir -p /home/builder/Build && \
   chown builder:builder /home/builder/Build

   VOLUME ["/home/builder/Build"]

   USER builder

   WORKDIR /home/builder/Build

   CMD ["bash"]
   ```

3. In the directory with the Docker file, execute

   ```sh
   docker -t jessie-armel-build:latest build .
   ```

## Using the container

* If you need additional packages or software you can install them by
using another Dockerfile with FROM jessie-armel-build:latest
and the appropriate Dockerfile commands for what you want to add.
* You may want to add a user with user and group id that matches the
user that owns /your/build/directory (below) and change the
USER *user* in the above Dockerfile (or your extending Dockerfile),
in order to avoid permissions issues.
* When you want an interactive shell that uses the software in the
container, you can do: docker run -it -v /your/build/directory:/home/builder/Build jessie-armel-build:latest bash

## Further Reading

* <https://docs.docker.com/develop/develop-images/baseimages/>
* ~~`https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/`~~
* <https://devdataops.de/post/2018/11/16/arm-on-x86-linux/>
* ~~`https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/`~~
* <https://www.debian.org/releases/stable/armel/apds03.en.html>
* <http://psellos.com/2012/08/2012.08.qemu-arm-osx.html>
* <https://franciscobenitezleon.wordpress.com/2010/02/05/installing-debian-lenny-on-virtualized-arm-arch-with-qemu-on-ubuntu-karmic-koala/>
* <http://cronicasredux.blogspot.com/2011/09/installing-and-running-debian-armel-on.html>
* <https://www.n0nb.us/blog/2012/03/a-qemu-image-for-debian-armel/>
