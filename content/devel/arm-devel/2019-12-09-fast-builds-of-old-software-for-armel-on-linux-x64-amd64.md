---
slug: fast-builds-of-old-software-for-armel-on-linux-x64-amd64
aliases:
    - /2019/12/09/fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
    - /2020/12/06/fast-cross-compile-of-linux-2-6-for-armel/
    - /post/fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
    - /post/fast-cross-compile-of-linux-2-6-for-armel/
    - /fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
    - /fast-cross-compile-of-linux-2-6-for-armel/
    - /docs/arm-development/cross-build/fast-cross-compile-of-linux-2-6-for-armel/
    - /develop-design/arm-development/cross-build/fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
    - /devel/fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
    - /devel/arm-devel/fast-builds-of-old-software-for-armel-on-linux-x64-amd64/
author: Daniel F. Dickinson
tags:
    - arm-devel
    - armel
    - armhf
    - cross-compile
    - devel
    - docs
    - linux
    - virtualization
date: '2019-12-09T06:40:00+00:00'
publishDate: '2019-12-09T06:40:00+00:00'
title: Fast builds of armel software on Linux x64
description: "The fastest and most practical way to build software for armel is to cross-compile on an x86_64 machine even for a Linux 2.6-series kernel"
weight: 9700
series:
    - debian-on-a-craig-clp281
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

Unless you have a new, high-powered, ARM system with which to build, the fastest and most practical way to build software for armel (early ARM CPU versions) is to cross-compile on an x86_64 machine (Debian and offshoots call this the amd64 architecture, even for non-AMD CPUs). Obtaining a working toolchain that is able to build a 2.6 (old) kernel is probably the hardest part of the exercise

## Why Use Cross-Compilation vs QEMU User Mode or VM to Emulate armel?

* Speed. It’s much faster, especially if you have multiple cores and
use parallel builds.
* QEMU user mode doesn’t support using more than one core (which
means not only are you doing emulation (which is slow), but you are
stuck with single-threaded builds.
* QEMU user mode is still useful for things like build a rootfs
because it allows you to use standard package management tools for
your distribution rather than requiring a real machine.
* Likewise QEMU user mode is useful for doing automated testing for
alternate architectures (like armel) on an x86 host.

## Preliminaries

* We’re going to use a cross-compilation toolchain, but we’re going to use do it on Debian Wheezy. We do this because we’re trying to build older software which often has incompatibilities with newer system, even when using cross-compilation with older toolchains.
* The instructions are written assuming we are running on a Debian system, however the host environment should not be relevant (it could even be Windows provided you have Docker for Windows).
* You need Docker on your system (apt-get install debootstrap docker.io)
* This article assumes you have Docker configured and running
* We use Docker because it provides more protection from shooting yourself in the foot than a chroot (which requires root access to initiate the chroot). It also provides better (but not complete) protection against exploits. Best (short of a virtual machine or dedicated host would be to run in an *unprivileged* container).
* For this exercise we are building for Linux kernel 2.6.32.9 as this is part of the series on getting [Debian working on the Craig CLP281](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1)

## Build the Development Environment Container

### Notes

* These instructions only produce an environment for compiling C and Assembler programs, not C++ or any other language.
* Normally you wouldn’t want to *build* your tools in the same container as you use for your environment, but in this case we are creating a development environment, so having the development tools in the container can be handy.

### Build the Container

1. Create a directory (e.g. mkdir workdir) and change to it (e.g. ``cd workdir``).
2. Create a file called Dockerfile such as the one below.

**NB**: If you want a different user id and group id than the default,
a different user and/or group name, and/or to set more than default of
one core (faster builds!) for compilation you can use a command line
such as:

```sh
docker build -t wheezy-cross-armel:latest --build-arg uid=1001 --build-arg gid=1001 --build-arg user=john --build-arg group=john build-arg cores=8.
```

### Dockerfile

```Dockerfile
FROM debian:wheezy

ARG uid=1000
ARG gid=1000
ARG user=builder
ARG group=${user}
ARG cores=

RUN echo "deb http://archive.debian.org/debian wheezy main contrib non-free" > /etc/apt/sources.list && \
 echo "deb-src http://archive.debian.org/debian wheezy main contrib non-free" >> /etc/apt/sources.list && \
 echo "deb http://archive.debian.org/debian-security wheezy/updates main contrib non-free" >> /etc/apt/sources.list && \
 echo "deb-src http://archive.debian.org/debian-security wheezy/updates main contrib non-free" >> /etc/apt/sources.list && \
 # APT CONF
 echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/archive && \
 apt-get update && \
 apt-get dist-upgrade -y

RUN apt-get install -y \
 bash-completion \
 binutils-dev \
 build-essential \
 bzip2 \
 cmake \
 curl \
 debhelper \
 dpkg-dev \
 diffutils \
 fakeroot \
 fakechroot \
 gawk \
 git \
 libgmp-dev \
 gnupg2 \
 libbfb0-dev \
 libc6-dev \
 libcurl4-gnutls-dev \
 libdw-dev \
 libelf-dev \
 libisl-dev \
 libtool \
 ncurses-dev \
 libmpc-dev \
 libmpfr-dev \
 pkg-config \
 python-minimal \
 quilt \
 texinfo \
 u-boot-tools \
 wget \
 xmlto \
 xz-utils \
 zlib1g-dev && \
 apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH "/opt/arm-linux-2.6/bin:$PATH"

RUN addgroup --gid ${gid} ${group} && adduser --uid ${uid} --gid ${gid} --disabled-password ${user} --gecos "" && \
 mkdir -p /home/${user}/Build && \
 chown ${user}:${group} /home/${user}/Build && \
 mkdir -p /opt/build && \
 chown -R ${user}:${group} /opt

USER ${user}:${group}

# Stage 1: Build binutils & initial gcc

RUN cd /opt/build && \
 curl -O https://mirror.csclub.uwaterloo.ca/gnu/binutils/binutils-2.25.tar.bz2 && \
 curl -O https://mirror.csclub.uwaterloo.ca/gnu/gcc/gcc-4.9.4/gcc-4.9.4.tar.bz2 && \
 tar -xjf binutils-2.25.tar.bz2 && \
 tar -xjf gcc-4.9.4.tar.bz2

RUN cd /opt/build && mkdir binutils-build && \
 cd binutils-build && \
 ../binutils-2.25/configure --quiet --prefix=/opt/arm-linux-2.6 --target=arm-linux-gnueabi --with-sysroot --disable-nls --disable-werror --disable-multilib && \
 make -j${cores} && \
 make install && \
 mkdir ../gcc-build && \
 cd ../gcc-build && \
 ../gcc-4.9.4/configure --quiet --prefix=/opt/arm-linux-2.6 --target=arm-linux-gnueabi --enable-languages=c --without-headers --disable-nls --enable-serial-configure --disable-multilib && \
 make -j${cores} all-gcc && \
 make install-gcc && \
 cd .. && \
 rm -f *.bz2

# Stage 2: Build glibc standard C library header files and startup files
# Stage 3: Go Back and Forth between GCC and Glibc as Required to Build Both

RUN cd /opt/build && \
 curl -O https://mirror.csclub.uwaterloo.ca/gnu/glibc/glibc-2.19.tar.bz2 && \
 curl -O https://mirror.csclub.uwaterloo.ca/kernel.org/linux/kernel/v2.6/linux-2.6.32.9.tar.bz2 && \
 tar -xjf glibc-2.19.tar.bz2 && \
 tar -xjf linux-2.6.32.9.tar.bz2

RUN cd /opt/build/linux-2.6.32.9 && \
 make ARCH=arm INSTALL\_HDR\_PATH=/opt/arm-linux-2.6/arm-linux-gnueabi headers\_install && \
 cd .. && \
 mkdir -p glibc-build && \
 cd glibc-build && \
 ../glibc-2.19/configure --quiet --prefix=/opt/arm-linux-2.6/arm-linux-gnueabi --build=$MACHTYPE --host=arm-linux-gnueabi --target=arm-linux-gnueabi --with-headers=/opt/arm-linux-2.6/arm-linux-gnueabi/include --disable-multilib libc\_cv\_forced\_unwind=yes && \
 make install-bootstrap-headers=yes install-headers && \
 make -j${cores} csu/subdir\_lib && \
 install csu/crt1.o csu/crti.o csu/crtn.o /opt/arm-linux-2.6/arm-linux-gnueabi/lib && \
 arm-linux-gnueabi-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/arm-linux-2.6/arm-linux-gnueabi/lib/libc.so && \
 touch /opt/arm-linux-2.6/arm-linux-gnueabi/include/gnu/stubs.h

RUN cd /opt/build/gcc-build && \
 make -j${cores} all-target-libgcc && \
 make install-target-libgcc

RUN cd /opt/build/glibc-build && \
 make -j${cores} && \
 make install

RUN cd /opt/build/gcc-build && \
 make -j${cores} && \
 make install && \
 cd /opt && rm -rf build

VOLUME ["/home/${user}/Build"]

WORKDIR /home/${user}/Build

CMD ["bash"]
```

## Using the container

* If you need additional packages or software you can use another
Dockerfile with FROM wheezy-cross-armel:latest
and the appropriate Dockerfile commands for what you want to add.
* When you want an interactive shell that uses the software in the
container, you can do: ``docker run -it -v /your/build/directory:/home/[your-user]/Build jessie-cross-armel:latest /bin/bash``

## Further Reading

* <https://docs.docker.com/develop/develop-images/baseimages/>
* <https://wiki.osdev.org/GCC_Cross-Compiler>
* <https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/>
* <https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain>

## Building a Linux 2.6 (Android-based) Kernel

For Craig CLP281 (WonderMedia WM8650)

1. Obtain the Linux 2.6 kernel you want to build. In this case:

   ``` shell
   git clone -b wmcshore-1.0 --depth 1 --recurse-submodules <https://git-large.wildtechgarden.ca/linux-kernel/wm8650-2.6-reference-kernel-build.git> --shallow-submodules wm8650-linux-2.6
   ```

2. Enter the cross-compilation environment (if not already there).
   1. Change to the directory in which you cloned the kernel source code, above (e.g. wm8650-linux-2.6)
   2. docker run -it -v $(pwd):/home/builder/Build wheezy-cross-armel:latest bash. **NB** If you used a different username when building the suggested cross-compilation environment use that instead of builder.
3. If you are using a different cross-compilation environment than built above, make sure that your PATH is pointing to your cross-compilation tools and that they are prefixed with ‘arm-linux-gnueabi-’ (e.g. /path/to/your/toolchain/bin/arm-linux-gnueabi-gcc). If that is not the case you will need to set your PATH and supply the appropriate CROSS_COMPILATION=your-compiler-prefix make flag for all make commands below.
4. Modify the config if you wish (but note that most configs won’t work and the released config which you got by cloning above is known to work).
   1. You can use make menuconfig and make backports-menuconfig to modify the kernel and backports modules (basically wireless).
5. Build the kernel, modules, and create a debian package as well as a tarball containing the kernel and modules.
   1. make J=X all (make will automatically do as much parallelism as possible). On a fast machine this could be done in 3-4 minutes.
6. Exit the cross-compilation environment.
7. You should have linux-image-\*.deb package in the, as well as linux-2.6.*.tar.bz2.
