---
slug: cross-compile-for-armel-using-an-arm-hf-vm
aliases:
- /2020/12/05/cross-compile-for-armel-using-an-arm-hf-vm/
- /docs/arm-development/cross-build/cross-compile-for-armel-using-an-arm-hf-vm/
- /develop-design/arm-development/cross-build/cross-compile-for-armel-using-an-arm-hf-vm/
- /devel/cross-compile-for-armel-using-an-arm-hf-vm/
- /docs/devel/arm-devel/cross-compile-for-armel-using-an-arm-hf-vm/
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
date: '2021-02-13T07:59:35+00:00'
publishDate: '2020-12-05T05:23:00+00:00'
title: Cross-compile for armel using an ARM HF VM
description: "This method of compiling for armel (e.g. ARMv5, earlier, and some ARMv6) uses pbuilder in an ARM hardFloat VM"
summary: "This method of compiling for armel (e.g. ARMv5, earlier, and some ARMv6) uses pbuilder in an ARM hardFloat VM"
weight: 9600
---

{{< details-toc >}}

## Preface

This method of compiling for armel (e.g. ARMv5, earlier, and some ARMv6) which uses pbuilder in an ARM HardFloat VM is not recommended as it is extremely slow (because of running in a emulated VM, not because of using pbuilder). However, it continues to be the best option for tasks like firmware image generation.

## You Need an ARM HardFloat VM

Build and boot an ARM HardFloat VM created using one of the methods pointed to by [Four ARMs for LibVirt KVM](arm-libvirt-kvm-virtualization/_index.md)

## Install and Configure pbuilder

``sudo apt install pbuilder``

### Create a pbuilder rootfs

For example, if you want to build in a ‘wheezy’ armel environment:

1. ``mkdir pbuilder-wheezy``
2. ``mkdir pbuilder-wheezy/tmp``
3. ``mkdir pbuilder-wheezy/cache``
4. ``mkdir pbuilder-wheezy/aptcache``
5. The main build command:

   ```sh
   sudo pbuilder create --basetgz pbuilder-wheezy/base.tgz --buildplace pbuilder-wheezy/tmp --buildresult pbuilder-wheezy/cache --distribution wheezy --architecture armel --aptcache pbuilder-wheezy/aptcache --mirror http://archive.debian.org/debian
   ```

### Add Additional Packages to pbuilder as Required

* This article takes this approach in order to illustrate how to add packages to an existing pbuilder rootfs because this workflow occurs often.
* You could use --extrapackages in the pbuilder command above if you already know what packages you need.
* To add packages like ‘make’ and vim-nox to an existing rootfs you might use:

  ```sh
  sudo pbuilder update --basetgz pbuilder-wheezy/base.tgz --buildplace pbuilder-wheezy/tmp --buildresult pbuilder-wheezy/cache --aptcache pbuilder-wheezy/aptcache --extrapackages "make vim-nox nano"
  ```

### Build Kernel (for example)

### Get a Copy of a 2.6 Kernel

In our case we’re going to clone the build system and linux 2.6 kernel from my WM8650 repo:

git clone -b wmcshore-1.0 --depth 1 --recurse-submodules <https://github.com/danielfdickinson/wm8650-gpl-reference-kernel-build> --shallow-submodules wm8650-2.6-reference-kernel-build

### Use pbuilder to build the kernel

1. Launch a pbuild ‘login’ with the kernel build directory bind mounted into the pbuilder chroot:

   ```sh
   sudo pbuilder login --basetgz pbuilder-wheezy/base.tgz --buildplace pbuilder-wheezy/tmp --buildresult pbuilder-wheezy/cache --aptcache pbuilder-wheezy/aptcache --bindmounts "$(pwd)/wm8650-gpl-reference-kernel-build"
   ```

2. In pbuilder login, change to your wm8650-2.6-reference-kernel-build directory. (e.g. cd /home/user/wm8650-2.6-reference-kernel-build).
3. Build the kernel (for this example all that we need to do is execute make).
4. Wait (a long time).
5. Once you are done, exit the login session.

## Copy the Build Artifacts

Copy artifacts (aka output/results) to where you can use them (this is just
standard Linux copying or remote copy, etc).
