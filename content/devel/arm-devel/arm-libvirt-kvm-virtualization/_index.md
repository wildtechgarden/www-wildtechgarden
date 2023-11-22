---
title: "ARM Libvirt/KVM virtualization"
slug: arm-libvirt-kvm-virtualization
aliases:
- /devel/arm-devel/arm-libvirt-kvm-virtualization/arm-libvirt/kvm-virtualization/
- /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/
- /projects/arm-development/four-arms-for-libvirt-kvm-virtualization/
- /four-arms-for-libvirt-kvm-virtualization/
- /post/four-arms-for-libvirt-kvm-virtualization/
- /projects/four-arms-for-libvirt-kvm-virtualization/
- /projects/four-arms-for-libvirt-kvm-virtualization/
- /project/arm-development/arm-firmware-builds/four-arms-for-libvirt-kvm-virtualization/
- /projects/arm-development/arm-firmware-builds/four-arms-for-libvirt-kvm-virtualization/
- /docs/arm-development/arm-libvirt-kvm-virtualization/
- /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/
- /develop-design/arm-development/arm-libvirt-kvm-virtualization/
- /devel/arm-libvirt-kvm-virtualization/
author: Daniel F. Dickinson
date: 2020-11-13T13:51:00+00:00
publishDate: 2020-11-09T16:52:00+00:00
description: "For 32-bit ARM, whether you want an old school or UEFI virtual
machine in Libvirt/KVM, and automated or ‘manual’ creation, here there are docs."
summary: "For 32-bit ARM, whether you want an old school or UEFI virtual
machine in Libvirt/KVM, and automated or ‘manual’ creation, here there are docs."
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm-devel
    - debian
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
frontCard: true
card: true
weight: 6000
showChildPages: false
---

{{< details-toc >}}

## Preface

Whether you want old school ARM (32-bit) or a shiny new UEFI ARM (32-bit) virtual
machine in Libvirt/KVM, and automated or ‘manual’ creation, there is a way to
get what you want. This post introduces the four ARMs and will point to the
four posts as they are added.

## The Posts

* Part 1: [Old school manual ARM for Libvirt/KVM](2020-11-09-old-school-manual-arm-for-libvirt-kvm.md)
* Part 2: [UEFI manual ARM for Libvirt/KVM](2020-11-10-uefi-manual-arm-for-libvirt-kvm.md)
* Part 3: [Old school automated ARM for Libvirt/KVM](old-school-automated-arm-for-libvirt/_index.md)
* Part 4: [UEFI automated ARM for Libvirt/KVM](uefi-automated-arm/_index.md)

## Prerequisites

### General

* A reason to be interested in an ARM hardfloat virtual machines (see [below](#arm-hard-float-32-bit-virtual-machines-with-debian-gnulinux))

### Knowledge

* Familiar with installing and using Debian
* Familiar with using common command line shells such as Bash
* Familiar with Libvirt/KVM configuration, setup, and usage
* Familiar with Virtual Machine Manager (virt-manager) for Libvirt
* Familiar with Libvirt command line shell virsh

### Tools, Equipment, and Software

* A host running Libvirt Daemon using KVM (or TCG)
* Libvirt configured to be accessed via SSH
* For automated provisioning versions, you need a copy of [Packer](https://www.packer.io/) and
(preferred) acceleration on the host that will run Packer
* Libvirt / Packer host doesn’t need to be running Debian

#### May be on a different host

* Virtual Machine Manager (virt-manager)
* virt-clients (virsh command line tool and more)
* libguestfs-tools (for guestfish command line tool)
* The instructions will be assuming these tools are run on a Debian or Ubuntu system

## What We are Making and Why

### ARM on Libvirt/KVM

* Two basic flavours: ‘native’ and ‘emulated’
  * ‘Native’ (where the virtual host is the same architecture as the virtual machine)
 virtual machines can generally use accelerators to get near native speed.
  * ‘Emulated’ virtualisation is generally slower because acceleration is generally
 not available because one is translating every machine instruction instead of
 sometimes running instructions directly (which is what acceleration allows).
* The techniques described here can be used in either scenario.
* We are using Libvirt/KVM because it is a common virtualisation platform freely available
for Linux that is quite convenient to use when is using virtualisation on hosts that
do other things (including Linux desktop) while still making sense for one or two
dedicated machines (i.e. where OpenStack etc would be overkill and/or suck up resources
unnecessarily).

### ARM Hard Float (32-bit) Virtual Machines with Debian GNU/Linux

* Compile software and/or kernels for multiple ARM architectures with native toolchains
  * Including armhf and armel machines of various ‘flavours’
  * Avoids the need to build a special cross-compilation toolchain
  * But…**SLOW**
  * Better for doing things like building rootfs images, running scripts in ARM chroot that doesn’t work properly in Debian Buster on 64-bit amd64 (at least) using a method such as using qemu-user-static and a Docker container due to a bug in the Linux kernel. See <https://bugs.launchpad.net/qemu/+bug/1805913>.
* Using a chroot one can use toolchains for old distributions to compile really old software and kernels for ARM machines (for example old kernels with proprietary parts that are not available in source version) as if one were doing so natively.
* Do note that because these are virtual machines, usually running on different architecture than the virtual host (i.e. not on ARM virtual hosts), performance will not be as high as a true native solution, but KVM ARM hardfloat allows us to use virtual machines with multiple emulated cores, which helps speed up things like compilation, if one uses parallel builds.
* Debian for the guest operating system was selected because it has had (and continues to have) excellent support for 32-bit ARM architectures, and this has been true for a very long time.

#### non-EFI (traditional) created interactively

* non-EFI Libvirt machines are easier to transfer to other virtual hosts (EFI
machines require copying the NVRAM variables to the virtual hosts where they
will be needed).
* interactive debian-installer is the easiest option to understand the process.

#### UEFI created interactively

* UEFI VMs are more ‘modern’ and secure in terms of firmware stack
* UEFI ARM virtual machines can boot natively from the virtual hard disk instead
of requiring a direct kernel boot like non-EFI VMs do.
* interactive debian-installer is the easiest option to understand the process.
* Does not require extracting the ‘kernel’ and ‘initramfs’ each time there is a
kernel update or the initramfs is regenerated, as non-EFI ARM hosts do.

#### non-EFI (traditional) create via an automated process using Packer

* non-EFI Libvirt machines are easier to transfer to other virtual hosts (EFI
machines require copying the NVRAM variables to the virtual hosts where they
will be needed).
* Automated image generation can be useful for preparing a CI/CD pipeline
* Automated image generation reduces chances for errors in the VM creation and
provisioning stages.
* Automation means an repeatable process.

#### UEFI created via an automated process using Packer

* UEFI VMs are more ‘modern’ and secure in terms of firmware stack (although for
these guides we are not taking full advantage this as enabling SecureBoot
complicates the process).
* UEFI ARM virtual machines can boot natively from the virtual hard disk instead
of requiring a direct kernel boot like non-EFI VMs do.
* Automated image generation can be useful for preparing a CI/CD pipeline
* Automated image generation reduces chances for errors in the VM creation and
provisioning stages.
* Automation means an repeatable process.
* Does not require extracting the ‘kernel’ and ‘initramfs’ each time there is a
kernel update or the initramfs is regenerated, as non-EFI ARM hosts do.
