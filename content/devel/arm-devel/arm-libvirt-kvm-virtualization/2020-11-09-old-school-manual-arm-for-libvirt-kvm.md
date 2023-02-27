---
slug: old-school-manual-arm-for-libvirt-kvm
aliases:
- /2020/11/09/old-school-manual-arm-for-libvirt-kvm/
- /old-school-manual-arm-for-libvirt-kvm/
- /post/old-school-manual-arm-for-libvirt-kvm/
- /docs/arm-development/arm-libvirt-kvm-virtualization/old-school-manual-arm-for-libvirt-kvm/
- /docs/devel/arm-develop/arm-libvirt-kvm-virtualization/old-school-manual-arm-for-libvirt-kvm/
- /develop-design/arm-development/arm-libvirt-kvm-virtualization/old-school-manual-arm-for-libvirt-kvm/
- /devel/old-school-manual-arm-for-libvirt-kvm/
author: Daniel F. Dickinson
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm
    - armhf
    - debian
    - devel
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
date: '2020-11-09T15:52:00+00:00'
publishDate: '2020-11-09T16:52:00+00:00'
description: Create a non-EFI (old school) ARMh hardfloat virtual machine for Libvirt/KVM using a traditional interactive Debian install.
summary: Create a non-EFI (old school) ARMh hardfloat virtual machine for Libvirt/KVM using a traditional interactive Debian install.
title: "Old school manual ARM for Libvirt/KVM"
toc: true
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

**NB** These instructions are out of date since the release of Debian 11 (Bullseye). Some parts of these guide will need to be updated to the new Debian release.

## Overview

* Create a non-EFI (old school) ARM hardfloat virtual machine for Libvirt/KVM using a traditional interactive Debian install.
* See [Four ARMs for Libvirt/KVM virtualisation](arm-libvirt-kvm.md) for prerequisites, why, and other alternatives.

## Get the Installer Images

**NB** Instead of vmlinuz and initrd.gz as the filenames you should use filenames that include the debian version and architecture (e.g. call vmlinuz debian-10.6.0-armhf-vmlinuz).

1. Get ~~[Debian Buster armhf kernel]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/vmlinuz``)~~
2. Get ~~[Debian Buster armhf initrd]\(``https://deb.debian.org/debian/dists/buster/main/installer-armhf/20190702+deb10u6../../assets/images/cdrom/initrd.gz``)~~
3. Get ~~[Debian Buster armhf CD#1 image]\(``https://mirror.csclub.uwaterloo.ca/debian-cd/10.6.0/armhf/iso-cd/debian-10.6.0-armhf-xfce-CD-1.iso``)~~

## Prepare to Use the Debian-Installer Image

Open the download location in a terminal.

### Copy the kernel, initrd, and CD image

1. sudo cp vmlinuz initrd.gz debian-10.6-buster-armhf-complete-image.img /var/lib/libvirt/images on the machine where you will host the ARM VM.

### OR upload kernel, initrd, and CD image using virsh

1. ```bash
   ls -al vmlinuz initrd.gz debian-10.6.0-armhf-xfce-CD-1.iso
   ```

2. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name vmlinuz --format raw --allocation \<size-from-ls> --capacity \<size-from-ls>
   ```

3. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol vmlinuz --file vmlinuz
   ```

4. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name initrd.gz --format raw --allocation \<size-from-ls> --capacity \<size-from-ls>
   ```

5. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol initrd.gz --file initrd.gz
   ```

6. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name debian-10.6.0-armhf-xfce-CD-1.iso --format raw --allocation \<size-from-ls> --capacity \<size-from-ls>
   ```

7. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol debian-10.6.0-armhf-xfce-CD-1.iso --file debian-10.6.0-armhf-xfce-CD-1.iso
   ```

## Create the ARM VM using Virtual Machine Manager

1. Launch “Virtual Machine Manager” (virt-manager from the command line).
2. Select ‘File|New Virtual Machine’
3. Select ‘Import existing disk image’
4. Change ‘Architecture options’ to Architecture: ‘arm’, Machine Type: ‘virt-2.12’. *(virt-3.0 and
virt-3.1 are known to not work with this guide; newer and older versions likely will work)*.
5. Select ‘Browse…’, create a virtual hard disk for the new VM, and select ‘Choose Volume’.
6. For each of the kernel and initrd, browse to the file and select ‘Choose Volume’.
7. Set ‘Kernel args’ to ‘elevator=noop noresume’.
8. Set the operating system to ‘Debian10’
9. Select ‘Forward’
10. Configure the amount of memory and cpus (max 4) and select ‘Forward’
11. Set the VM name and check ‘Customize configuration before install`
12. Select the appropriate network device for your virtual hosting setup.
13. Click ‘Finish’
14. Select ‘Add Hardware’, and add a Controller of ‘Type: SCSI’ and ‘Model: VirtIO SCSI’.
15. Select ‘Add Hardware’, and add Storage (CD-ROM) for the CD ISO image (use SCSI as the bus type).
16. Select ‘Begin installation’
17. Make sure to select the VM console when it appears otherwise random errors may occur.

## Perform Debian Installation

I won’t cover this in detail as it’s a fairly standard Debian install except:

1. These instruction assume you don’t use LVM.
2. GRUB installation will fail. This is expected — we will work around this below.
3. Click through (OK/Continue/Ignore) until you are able to Select ‘Continue without bootloader’
4. Installation will complete and the VM will reboot into the installer.
5. Force Off the VM (e.g. in VMM with ‘Virtual Machine|Force Off’)
6. Remove the CD image from the CD-ROM (optionally remove the virtual CD-ROM device too; you won’t need it).

## Enable Booting the Virtual Machine

**NB** You will need to repeat this whenever the initramfs and/or kernel is updated.

### Copy the kernel and initramfs from the domain (VM)

So that you can use it to boot the domain (VM).

On the virtual machine host:

1. Become root
2. Execute ``mkdir /tmp/armbootfiles``
3. Execute ``chmod 700 /tmp/armbootfiles``
4. Execute ``cd /tmp/armbootfiles``
5. Execute ``guestfish -c qemu:///system --ro -i -d \<name-of-your-vm>``
6. Execute ``ls /boot`` to find the names of the newest vmlinuz and initrd.img (you don’t want the plain vmlinuz and initrd.img because they are just symlinks).
7. Execute

   ```bash
   copy-out /boot/vmlinuz-x.x-x.x-armmp-lpae /boot/initrd.img-x.x.x-x-armmp-lpae ./
   ```

8. Execute exit
9. Execute ``prename -e 's/^/\<name-of-your-vm>/' *``
10. Execute ``mv \<name-of-your-vm>-* /var/lib/libvirt/images``
11. Execute exit

### Edit the domain (VM) to update the direct boot

Using the kernel and initrd from the VM.

1. In Virtual Machine Manager, in the VM Details page, Select ‘Boot Options’
2. Make sure ‘Enable direct kernel boot’ is checked.
3. For the ‘Kernel Path’, ‘Browse’ to the location of the new kernel and select ‘Choose Volume’
4. For the ‘Initrd Path’, ‘Browse’ to the location of the new initrd.img and select ‘Choose Volume’
5. Add ``root=/dev/vda2`` to ‘Kernel args’. (If you used LVM the path will be slightly different).
6. Select ‘Apply’

#### Alternative method to edit domain (VM)

1. Execute ``virsh -c qemu+ssh://user@host/system edit \<name-of-domain>``
2. Place the appropriate paths in the \<kernel>…\</kernel> and \<initrd>…\</initrd> tags.
3. Also edit the \<cmdline>…\</cmdline> to add root=/dev/vda2 as above.
4. Save your changes.

## Boot to Test

Test that your system now boots properly by using ‘Virtual Machine|Run’.
