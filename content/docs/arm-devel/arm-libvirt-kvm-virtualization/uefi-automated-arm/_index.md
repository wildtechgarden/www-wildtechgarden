---
title: "UEFI automated ARM for Libvirt/KVM"
slug: uefi-automated-arm
aliases:
- /2020/11/16/uefi-automated-arm/
- /post/uefi-automated-arm/
- /uefi-automated-arm/
- /docs/arm-development/arm-libvirt-kvm-virtualization/uefi-automated-arm/
- /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/uefi-automated-arm/
- /develop-design/arm-development/arm-libvirt-kvm-virtualization/uefi-automated-arm/
- /devel/uefi-automated-arm/
- /devel/arm-devel/arm-libvirt-kvm-virtualization/uefi-automated-arm-vm/uefi-automated-arm/
author: Daniel F. Dickinson
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm-devel
    - debian
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
date: 2020-11-16T12:32:00+00:00
publishDate: 2020-11-16T12:32:00+00:00
description: Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using automated image build using Packer.
summary: Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using automated image build using Packer.
showChildPages: false
---

{{< details-toc >}}

**NB** These instructions are out of date since the release of Debian 11 (Bullseye). Some parts of these guide will need to be updated to the new Debian release.

## Overview

* Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using automated image build using [Packer](https://www.packer.io).
* See [Four ARMs for Libvirt/KVM virtualisation](../_index.md) for prerequisites, why, and other alternatives.

## Get the Installer Images

**NB** Instead of vmlinuz and initrd.gz as the filenames you should use filenames that include the
debian version and architecture (e.g. call vmlinuz debian-10.6.0-armhf-vmlinuz).

1. ~~Get [Debian Buster armhf kernel]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/vmlinuz``)~~
2. ~~Get [Debian Buster armhf initrd]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/initrd.gz``)~~
3. ~~Get [Debian Buster armhf CD#1 image]\(``https://mirror.csclub.uwaterloo.ca/debian-cd/10.6.0/armhf/iso-cd/debian-10.6.0-armhf-xfce-CD-1.iso``)~~ Buster is no longer available for download; for the current version of Debian see <https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/>. The instructions in this article have not yet been updated for Bullseye, however.

Subsequent instructions assume you have the renamed files in /home/user/Downloads.

## Create and Use the Images

* [Create the Image and Boot Files](create-image-and-boot-files.md)
* [Use the Image](use-the-image.md)

## Boot at Will

Your UEFI ARM Hard Float Virtual Machine is now ready for use.
