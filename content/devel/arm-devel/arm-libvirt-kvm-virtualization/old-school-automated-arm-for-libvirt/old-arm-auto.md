---
slug: old-school-automated-arm-for-libvirt
aliases:
- /2020/11/13/old-school-automated-arm-for-libvirt/
- /post/old-school-automated-arm-for-libvirt/
- /old-school-automated-arm-for-libvirt/
- /docs/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/
- /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/
- /develop-design/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/
- /devel/old-school-automated-arm-for-libvirt/
author: Daniel F. Dickinson
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm-devel
    - armhf
    - debian
    - devel
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
date: '2020-11-13T13:50:00+00:00'
publishDate: '2020-11-13T13:50:00+00:00'
description: Create a non-EFI (old school) ARM hardfloat virtual machine for Libvirt/KVM using packer to automate a repeatable process.
title: "Old school automated ARM for Libvirt/KVM"
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

**NB** These instructions are out of date since the release of Debian 11 (Bullseye). Some parts of these guide will need to be updated to the new Debian release.

## Overview

* Create a non-EFI (old school) ARM hardfloat virtual machine for Libvirt/KVM using packer to automate a repeatable process. The resulting image is meant to be used along with subsequent Packer provisioning to create a Libvirt base image, not be be used directly (although you can).
* See [Four ARMs for Libvirt/KVM virtualisation](../_index.md) for prerequisites, why, and other alternatives.

## Get the Installer Images

**NB** Instead of vmlinuz and initrd.gz as the filenames you should use filenames that include the
debian version and architecture (e.g. call vmlinuz debian-10.6.0-armhf-vmlinuz).

1. Get ~~[Debian Buster armhf kernel]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/vmlinuz``)~~
2. Get ~~[Debian Buster armhf initrd]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/initrd.gz``)~~
3. Get ~~[Debian Buster armhf CD#1 image]\(``https://mirror.csclub.uwaterloo.ca/debian-cd/10.6.0/armhf/iso-cd/debian-10.6.0-armhf-xfce-CD-1.iso``)~~

Subsequent instructions assume you have the renamed files in /home/user/Downloads.

## Create and Use the Images

* [Create the Image and Boot Files](create-image-and-boot-files.md)
* [Use the Image](use-the-image.md)

## Conclusion

This is a little more involved than the first two posts in this series where we
just did a standard Debian install, but it has the advantage that you can now
repeatably produce base virtual machine images. If you learn Ansible (or one
of the other provisioners for which Packer has a plugin) you can have the virtual
machine preconfigured to suit your needs, and if you need to you can tweak and
rebuild knowing you haven’t missed some provisioning step (which is a hazard with
manual provisioning).
