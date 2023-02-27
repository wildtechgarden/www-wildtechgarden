---
slug: replace-android-with-debian-on-a-craig-clp281-netbook
aliases:
   - /2019/11/30/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /post/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /posts/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /post/booting-debian-craig-clp281-netbook/
   - /posts/booting-debian-craig-clp281-netbook/
   - /replace-android-with-debian-on-a-craig-clp281-netbook/
   - /projects/defunct/craig-clp281/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /develop-design/arm-development/craig-clp281/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /devel/replace-android-with-debian-on-a-craig-clp281-netbook/
   - /docs/devel/arm-devel/replace-android-with-debian-on-a-craig-clp281-netbook/
author: Daniel F. Dickinson
tags:
    - archived
    - arm-devel
    - armel
    - armhf
    - craig-clp281
    - debian
    - devel
    - firmware
    - linux
    - projects
    - rootfs-images
date: '2019-11-30T08:41:00+00:00'
publishDate: '2019-11-30T08:41:00+00:00'
description: 'This article describes using Devuan Jessie as the firmware on one such: a Craig CLP281 Netbook.'
summary: 'This article describes using Devuan Jessie as the firmware on an originally Android-based Craig CLP281 netbook.'
title: Swap Devuan for Android on a Craig CLP281
weight: 9750
series:
    - debian-on-a-craig-clp281
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## NOTICE

**WARNING** You could brick (render unusable and unrecoverable) your
device while attempting to follow these instructions. Please make sure
you know what you are doing and are prepared for the risks. Obviously
you follow (or modify) these instructions **entirely at your own
risk**.

## A Note For Less Adventurous Users

With the instructions here it is necessary to have access to the serial port. If you prefer not open the device (physically) or do not wish to risk bricking (rendering unusable and unrecoverable) your device, and just want to run Debian from and SD card, see my article on [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/).

## Preliminaries

It would be helpful to be familiar with my article on [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/), as it contains much of the basic information about the Craig CLP281.

## Hardware — Unassembled

### Disassembly

* This is mostly a case of removing screws and being careful, so not
detailed here.
* Leave the monitor hooked up to the mainboard, otherwise you have
desolder the power button which is soldered directly to the mainboard and monitor. This also is needed for the power button to
be available.
* Removing the keyboard is a pain due to no play on the ribbon cable
attaching it to the mainboard (and reassembly is likewise
annoying). You need to pull out the latch for the socket for the
ribbon cable on mainboard and then gently pull out the ribbon
cable.

### Serial header

The serial header on these devices is unpopulated but the holes are
open (not filled with solder), so it is relatively easy to temporarily
connect a serial to USB cable to the header (this allows to monitor
and/or modify U-Boot settings).

Viewed from the top and with the mainboard oriented as it is in the case
when the keyboard is towards the user, and display to the back of the unit, the serial header of the Craig CLP281 is on the middle right of
the mainboard.

#### Pinouts

| Name   | Map | Map | Map | Map |
| ------ | --- | --- | --- | --- |
| Pin    | 1   | 2   | 3   | 4   |
| Signal | Vcc | RX  | TX  | GND |

Pin one (1) / Vcc is denoted by a square circuit pad compared to a round circuit pad for each of the holes of the unpopulated serial header.

![Image of opened CLP281 with Vcc indicated on circuit board](/assets/images/craig-clp281-arm-netbook-serial-port-annotated.jpg)

## Installing Devuan as The Firmware

### First Steps

#### Get Debian Running from SD Card First

It will save you a lot of grief to make sure you have Debian successfully running from SD Card before making the leap to replacing the firmware. See [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/) for information on doing that.

#### Make Sure U-Boot Networking is Working

This is required in case something goes wrong and you want to revert to
the stock (Android) firmware.

#### Make Sure You Know How to Use U-Boot to Recover

Discussing this is beyond the scope of this article, but you should be
able to find information via web search.

#### Backup the Flash Contents

This is required in case something goes wrong and you want to revert to
the stock (Android) firmware.

1. While booted into Devuan from the SD Card, make sure mtd-utils
is installed. E.g. ``apt-get install mtd-utils``

While on the Craig CLP281 execute the following script (in a location with at least 5GB free space), and copy the resulting .bin files to a safe place.

```sh
for mtddev in $(seq 6 16); do
 nanddump --oob --bb=dumpbad --forcebinary -f backup-mtd$mtddev.bin /dev/mtd${mtddev}
done
for mtddev in $(seq 0 5); do
 dd if=/dev/mtd${mtddev} of=backup-mtd${mtddev}.bin
done
```

### Prepare the Operating System

#### Build or Obtain a Suitable Kernel

Build a kernel as shown in [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/).

#### Build a Devuan Jessie Rootfs

Build a rootfs as shown in [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/#build-a-devuan-jessie-rootfs).

#### Copy the Rootfs to SD Card

As detailed in the [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/#copy-the-rootfs-to-the-sd-card)

#### Copy the Kernel to the SD Card

Following [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1) this will already be included in the rootfs.

#### Boot from the SD Card

As detailed in the [(Almost) Modern Debian on a Craig CLP281 Netbook](2019-11-24-almost-modern-debian-on-a-craig-clp281-netbook-v1/#final-steps) **NB**: Make a copy of the what appears on the serial console as you boot. Also, keep a copy of the output of dmesg after logging in after a fresh boot.

### Switch Over to Booting From Flash in Stages

#### Make a Copy of the Rootfs in a Subdirectory on the SD Card

1. On the CLP281: Identify partition LocalDisk from ``cat /proc/mtd`` (it should be large)
   1. Find the exact size of LocalDisk using cat ``/proc/mtd`` and
   dmesg (immediately after boot).
   1. Since we’re going to be running from flash it’s probably a good idea
   to disable logging.
      1. /etc/init.d/rsyslog stop
      2. update-rc.d rsyslog disable
   1. Install flash tools ``apt-get install mtd-utils u-boot-tools``
2. Shutdown and remove the SD Card
3. On a linux host: ``apt-get install rsync``
   1. Mount the SD Card on ``/mnt``
   2. ``mkdir wheezy-clp281-rootfs``
   3. ``sudo rsync -arltDHAXx --info=progress2 /mnt/ wheezy-clp281-rootfs``
   4. ``mkdir -p /mnt/root/rootfs``
   5. ``sudo rsync -arltDHAXx --info=progress2 wheezy-clp281-rootfs/ /mnt/root/rootfs``
   6. ``sync`` – this will take a while as the data is flushed

#### Modify the Mounts (Fstab) on the Rootfs

1. ``sudoedit /mnt/root/rootfs/etc/fstab``
2. Modify ``/etc/fstab`` to point to the root partition you will be using. E.g. Replace ``/dev/mmcblk0p3 / ext4 defaults 0 1`` with ``ubi0:rootfs_vol / ubifs defaults 0 0``
3. ``sudo eject /mnt``

#### Create the Rootfs on NAND Flash (on the CLP281)

For this discussion we are assuming that LocalDisk is on
``/dev/mtd16``. If this is not true for your system, adjust
accordingly. Identify LocalDisk by executing ``cat /proc/mtd``

1. Boot from the SD card
2. Log in as root (or become root).
3. ``cd /root``
4. Make a copy of LocalDisk
   1. ``nanddump --oob --bb=dumpbad --forcebinary -f backup-LocalDisk.bin /dev/mtdXX``
5. ``ubiformat /dev/mtd16- ubiattach -p /dev/mtd16 -d 0- ubimkvol /dev/ubi0 -N rootfs_vol -m- ‘‘mkfs.ubifs -r rootfs -x favor_lzo /dev/ubi0_0``

#### Boot From the Rootfs on NAND Flash (using SD Card as Boot)

While still booted on CLP281:

1. `cd /boot`
2. Make backups of `wmt_scriptcmd.src` and `wmt_scriptcmd`
3. `sudoedit wmt_scriptcmd.src` — this should be the boot script you
created previously. If not, you’ll need to copy it or recreate it.
4. Replace `setenv bootargs mem=${memtotal} root=/dev/mmcblk0p3 noinitrd rw rootfstype=ext4 console=tty1 console=ttyS0,115200n8 lpj=${lpj} ${platform_bootargs} init=/sbin/init rootdelay=1`
With `setenv bootargs mem=${memtotal} ubi.mtd=16 root=ubi0:rootfs_vol noinitrd rw rootfstype=ubifs console=tty1 console=ttyS0,115200n8 lpj=${lpj} ${platform_bootargs} init=/sbin/init rootdelay=1` — assuming your LocalDisk is `/dev/mtd16`.
5. `mkimage -A arm -O linux -T script -C none -n "Boot Debian" -a 0 -e 0 -d wmt_scriptcmd.src wmt_scriptcmd`
6. Reboot — e.g. `shutdown -r now`

#### Verify You Have Booted From NAND Rootfs

1. Log in as root
2. `mount`
3. You should see something like:

   ```conf
   ubi0:rootfs_vol on / type ubifs (rw,relatime)
   /dev/mmcblk0p1 on /boot type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=cp437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
   ...
   ```

4. Remove the `/dev/mmcblk0p1 /boot ...` line from `/etc/fstab`

#### Copy Kernel to NAND Flash and Boot From it Using SD Card

1. cd ``/boot``
2. Identify ``kernel-NAND`` from ``cat /proc/mtd``
3. Make a copy of kernel-NAND
   1. ``nanddump --oob --bb=dumpbad --forcebinary -f backup-kernel-NAND.bin /dev/mtdXX``
4. Copy the kernel image to NAND
   1. ``flash_erase /dev/mtdXX 0 0``
   2. ``nandwrite -m -p /dev/mtdXX uzImage.bin``
5. Make backups of ``wmt_scriptcmd.sr``c and ``wmt_scriptcmd``
6. ``ls -al uzImage.bin``
7. Take the size of ``uzImage.bin`` above. You will use that for [size] below.
8. Modify ``wmt_scriptcmd.src`` and replace ``mmcinit 0 fatload mmc 0 0x0 uzImage.bin`` with ``nandrw r 0x2600000 0x0 [size]``  
   **NB** Verify the ``0x2600000`` by looking at the output from dmesg that shows the start offset of ``kernel-NAND``.
9. `mkimage -A arm -O linux -T script -C none -a 0x0 -e 0x0 -n "Boot Debian" -d wmt_scriptcmd.src wmt_scriptcmd`
10. Reboot with serial console attached to the CLP281.
11. The serial console should show that you are booting the kernel from NAND flash.

### Use Swap on NAND flash

**NB** Only do this if you absolutely must (e.g. running even a light desktop like LXDE and trying to do anything ‘real’). It would be far better to stick to a thin client scenario (no browser, no office suite, no graphics program, just tunnel X11 over SSH or similar lightweight protocols to use a remote system) if you must have a graphical environment. It can, however do reasonably well as a CLI environment.

1. ``mount /dev/mmbclk0p1 /boot``
2. ``cd /boot``
3. Identify ``android-dat``a from ``cat /proc/mtd``
4. Make a copy of ``android-data``
   1. ``nanddump --oob --bb=dumpbad --forcebinary -f backup-android-data.bin /dev/mtdXX``
5. Format ``android-data`` for use by ubi block driver and attach it.
    1. ``ubiformat /dev/mtd14``
    2. ``ubiattach -p /dev/mtd14 -d 1``
6. Create an UBI volume.
   1. ``ubimkvol /dev/ubi1 -N swap_vol -m``
7. Identify the new MTD device for the UBI volume via cat ``/proc/mtd``.
8. Create swap on ``swap_vol``: ``mkswap /dev/mtdblockXX``
9. Activate swap: ``swapon /dev/mtdblockXX``
10. Add the new volume to fstab and boot (kernel) commandline
    1. Add the following to ``/etc/fstab`` ``/dev/mtdblockXX sw swapon defaults 0 0``
    2. Edit wmt_scriptcmd.src:
    3. ``Add ubi.mtd=XX`` to the **end** of the setenv bootargs line.
    4. ``mkimage -A arm -O linux -T script -C none -a 0x8000 -e 0x8000 -n "Boot Debian" -d wmt_scriptcmd.src wmt_scriptcmd``
    5. ``sync``
    6. ``umount /boot``
11. Reboot
12. As root execute ``swapon -s``
13. You should see:

    ```text

    Filename Type Size Used Priority
    /dev/mtdblock18 partition 507992 0 -1
    ```

#### Modify U-Boot to Boot From NAND

1. Reboot with serial console active, and as the system is booting,
keep pressing ENTER in the serial console, until you get a WMT #
prompt. NB. If autoboot reaches 0 (zero) and you system boots
normally you will have to reboot and try again.- Save the old u-boot environment variables (substituting your MTD
devices if different than below), and set up the new:

   ```bash
   setenv old-kernel-NAND_ofs ${kernel-NAND_ofs}
   setenv old-kernel-NAND_len ${kernel-NAND_len}
   setenv old-bootcmd ${bootcmd}
   setenv kernel-NAND_len [length-of-your-kernel-from-previous-steps]
   setenv newkernelargs 'setenv bootargs mem=${memtotal} ubi.mtd=16 root=ubi0:rootfs_vol noinitrd rw rootfstype=ubifs console=ttyS0,115200n8 console=tty1 lpj=${lpj} ${platform_bootargs} init=/sbin/init rootdelay=1 ubi.mtd=14'
   setenv bootcmd 'display init force ; nandrw r ${kernel-NAND_ofs} 0x0 ${kernel-NAND_len}; if iminfo 0x0; then run newkernelargs; bootm 0x0; fi; echo No kernel found'
   saveenv
   poweroff
   ```

2. Remove SD card & power on the system.- You should boot into your Debian system using only flash.

## Revert to Stock Android

### Set your SD Card to boot from SD Card, not Flash

1. Copy your first backed up wmt_scriptcmd back as the script to use. This should be the script that boots from SD Card.
2. Boot from the SD Card.
3. If you execute mount you should see something like:

   ```conf
   /dev/root on / type ext4 (rw,relatime,barrier=1,data=ordered)
   tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=20960k,mode=755)
   tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
   proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
   sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
   tmpfs on /dev type tmpfs (rw,relatime,size=10240k,mode=755)
   tmpfs on /run/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=146960k)
   devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620)
   /dev/mmcblk0p1 on /boot type vfat (rw,nosuid,nodev,relatime,fmask=0022,dmask=0022,codepage=cp437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
   ```

### Restore Partition Data

**NB** This will only work if there are no bad sectors on the flash. If
there are bad sectors on flash then Android will not work correctly.

1. Restore the Swap Partition (which is the android-data)
   1. ``cd /boot`` (assuming you stored the partitions here)
   2. Identify android-data mtd device.
   3. ``flash_erase /dev/mtdXX 0 0``
   4. ``nandwrite -k -o -p /dev/mtdXX [your-nanddump-backup-of-android-data.bin]``
2. Restore the Kernel Partition (which is the android kernel)
   1. Identify kernel-NAND mtd device
   2. ``flash_erase /dev/mtdXY 0 0``
   3. ``nandwrite -k -o -p /dev/mtdXY [your-nanddump-backup-of-kernel-NAND.bin]``
3. Restore the LocalDisk Partition (internal user storage)
   1. cd ``/root`` (assuming you still have the LocalDisk backup
 there).
   2. Identify LocalDisk mtd device
   3. ``flash erase /dev/mtdXZ 0 0``
   4. ``nandwrite -k -o -p /dev/mtdXZ [your-nanddump-backup-of-LocalDisk.bin]``

### Restore the U-Boot Environment

1. Reboot with serial console active, press ENTER until you get the
WMT # prompt.

   ```bash
   setenv kernel-NAND_ofs ${old-kernel-NAND_ofs}
   setenv kernel-NAND_len ${old-kernel-NAND_len}
   setenv bootcmd ${old-bootcmd}
   saveenv
   poweroff
   ```

2. Remove SD card & boot system.- You should be back in Android.

If reverting to flash does not succeed, check if you have bad sectors
on flash (you should get messages on the serial console and in dmesg if
you do. You can also use mtd-utils tools to help examine the
situation). If you have bad cells, you may be out of luck (although
probably the device was having issues prior to flashing Debian anyway
due to unreliable flash erase blocks).

## Useful information

* <https://kernelhacks.blogspot.com/2012/06/building-wm8650-netbook-kernel.html>
* ~~``http://philherlihy.com/adventures-in-armel-debian-wheezy-udevdxxx-unable-to-receive-ctrl-connection-function-not-implemented/``~~
* <https://github.com/vir91/wm8650-gpl-reference-kernel>
* <http://linux-mtd.infradead.org/faq/ubifs.html>
