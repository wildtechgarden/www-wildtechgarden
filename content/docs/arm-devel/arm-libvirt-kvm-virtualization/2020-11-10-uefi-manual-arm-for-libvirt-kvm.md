---
slug: uefi-manual-arm-for-libvirt-kvm
aliases:
- /2020/11/10/uefi-manual-arm-for-libvirt-kvm/
- /uefi-manual-arm-for-libvirt-kvm/
- /post/uefi-manual-arm-for-libvirt-kvm/
- /docs/arm-development/arm-libvirt-kvm-virtualization/uefi-manual-arm-for-libvirt-kvm/
- /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/uefi-manual-arm-for-libvirt-kvm/
- /develop-design/arm-development/arm-libvirt-kvm-virtualization/uefi-manual-arm-for-libvirt-kvm/
- /devel/uefi-manual-arm-for-libvirt-kvm/
author: Daniel F. Dickinson
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm-devel
    - debian
    - devel
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
date: '2020-11-10T16:55:00+00:00'
publishDate: '2020-11-10T16:55:00+00:00'
description: Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using a traditional interactive Debian install.
summary: Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using a traditional interactive Debian install.
title: "UEFI manual ARM for Libvirt/KVM"
---

{{< details-toc >}}

**NB** These instructions are out of date since the release of Debian 11 (Bullseye). Some parts of these guide will need to be updated to the new Debian release.

## Overview

* Create an UEFI (newish) ARM hardfloat (32-bit) virtual machine for Libvirt/KVM using a traditional interactive Debian install.
* See [Four ARMs for Libvirt/KVM virtualisation](_index.md) for prerequisites, why, and other alternatives.

## Get the Installer Image

1. Get ~~[Debian Buster armhf CD#1 image]\(``https://mirror.csclub.uwaterloo.ca/debian-cd/10.6.0/armhf/iso-cd/debian-10.6.0-armhf-xfce-CD-1.iso``)~~

## Prepare to Use the Debian-Installer Image

Open the download location in a terminal.

### Copy the CD image

1. On the machine where you will host the ARM VM:

   ```bash
   sudo cp debian-10.6-buster-armhf-complete-image.img /var/lib/libvirt/images
   ```

### OR upload CD image using virsh

1. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name debian-10.6.0-armhf-xfce-CD-1.iso --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

2. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol debian-10.6.0-armhf-xfce-CD-1.iso --file debian-10.6.0-armhf-xfce-CD-1.iso
   ```

## Create the ARM VM using Virtual Machine Manager

1. Launch “Virtual Machine Manager” (virt-manager from the command line).
2. Select ‘File|New Virtual Machine’
3. Select ‘Import existing disk image’
4. Change ‘Architecture options’ to Architecture: ‘arm’, Machine Type: ‘virt-2.12’. *(virt-3.0 and
virt-3.1 are known to not work with this guide; newer and older versions likely will work)*.
5. Select ‘Browse…’, create a virtual hard disk for the new VM, and select ‘Choose Volume’.
6. Set the operating system to ‘Debian10’
7. Select ‘Forward’
8. Configure the amount of memory and cpus (max 4) and select ‘Forward’
9. Set the VM name and check ‘Customize configuration before install`
10. Select the appropriate network device for your virtual hosting setup.
11. Click ‘Finish’
12. Change ‘Firmware’ to ‘Custom: /usr/share/AAVMF/AAVMF32\_CODE.fd’ and click ‘Apply’.
13. Select ‘Add Hardware’, and add a Controller of ‘Type: SCSI’ and ‘Model: VirtIO SCSI’.
14. Select ‘Add Hardware’, and add Storage (CD-ROM) for the CD ISO image (use SCSI as the bus type).
15. Under ‘Boot Options’ make sure ‘SCSI CD-ROM 1’ is checked and second (after VirtIO Disk 1)
16. Select ‘Begin installation’
17. Make sure to select the VM console when it appears otherwise random errors may occur.

## Perform Debian Installation

I won’t cover this in detail as it’s a fairly standard Debian install except:

1. Installation will complete and the VM will reboot into the installer.
(This misbehaviour may depend on the version of libvirt you are using; if you
are fortunate the VM will simply boot into Debian directly).
2. Force off the VM (e.g. in VMM with ‘Virtual Machine|Force Off’)
3. Remove the CD image from the CD-ROM (optionally remove the virtual CD-ROM
device too; you won’t need it).

## Enable VM (domain) Boot into Debian

1. Boot the VM (e.g. using ‘Virtual Machine|Run’).
2. It will drop to a UEFI shell.
3. Execute `bcfg boot add 0 FS0:EFI\debian\grubarm.efi "Linux"`
4. Execute `reset`
5. VM should reboot into Debian GNU/Linux.

## Boot at Will

Your UEFI ARM hardfloat virtual machine is now ready for use.
