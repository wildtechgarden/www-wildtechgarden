---
slug: create-image-and-boot-files
aliases:
    - /docs/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/create-image-and-boot-files/
    - /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/create-image-and-boot-files/
    - /develop-design/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/create-image-and-boot-files/
    - /devel/old-school-automated-arm-for-libvirt/create-image-and-boot-files/
title: "Create old school ARM image and boot files"
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
description: Create a non-EFI (old school) ARM Hard Float virtual machine image and boot files for Libvirt/KVM.
---

{{< details-toc >}}

## Setup the Packer Environment

### Prequisites

1. The packer executable found in the download for your system at <https://www.packer.io> (Download button) needs to be in a directory that is in your PATH.
2. Packer’s prequisites including QEMU in your PATH.
3. A directory for your packer files.
4. In the packer file directory, a subdirectory named preseed-dir.

#### Debian preseed file

A Debian preseed file preseed-arm-no-efi.cfg such as the one shown here, in the preseed-dir subdirectory:

**NOTE** This file has default root password defined. Obviously this is not intended
to be the final image, not for the image to be exposed to a network (the intention is
for the image to be fed to a Packer provisioning run).

```config
# Contents of the preconfiguration file (for buster)
# Localization
# Preseeding only locale sets language, country and locale.
#d-i debian-installer/locale string en_US
# The values can also be preseeded individually for greater flexibility.
d-i debian-installer/language string en
d-i debian-installer/country string CA
d-i debian-installer/locale string en_CA.UTF-8

# Optionally specify additional locales to be generated.
#d-i localechooser/supported-locales multiselect en_US.UTF-8, nl_NL.UTF-8
d-i localechooser/supported-locales multiselect en_US.UTF-8, en_GB.UTF-8

# Keyboard selection.
d-i keyboard-configuration/xkb-keymap select us
# d-i keyboard-configuration/toggle select No toggling

### Network configuration

# netcfg will choose an interface that has link if possible. This makes it
# skip displaying a list if there is more than one interface.
d-i netcfg/choose_interface select auto

# To set a different link detection timeout (default is 3 seconds).
# Values are interpreted as seconds.
#d-i netcfg/link_wait_timeout string 10

# If you have a slow dhcp server and the installer times out waiting for
# it, this might be useful.
#d-i netcfg/dhcp_timeout string 60
#d-i netcfg/dhcpv6_timeout string 60

# If non-free firmware is needed for the network or other hardware, you can
# configure the installer to always try to load it, without prompting. Or
# change to false to disable asking.
#d-i hw-detect/load_firmware boolean true
d-i hw-detect/load_firmware boolean false

### Mirror settings
# If you select ftp, the mirror/country string does not need to be set.
d-i mirror/protocol string http
d-i mirror/country string Canada
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

# Suite to install.
#d-i mirror/suite string testing
d-i mirror/suite string buster
# Suite to use for loading installer components (optional).
#d-i mirror/udeb/suite string testing

### Account setup
# Skip creation of a root account (normal user account will be able to
# use sudo).
d-i passwd/root-login boolean true
# Alternatively, to skip creation of a normal user account.
d-i passwd/make-user boolean false

# Root password, either in clear text
#d-i passwd/root-password password r00tme
#d-i passwd/root-password-again password r00tme
d-i passwd/root-password password example-provision-password
d-i passwd/root-password-again password example-provision-password
# or encrypted using a crypt(3) hash.
#d-i passwd/root-password-crypted password [crypt(3) hash]

# To create a normal user account.
#d-i passwd/user-fullname string Debian User
#d-i passwd/username string debian
# Normal user's password, either in clear text
#d-i passwd/user-password password insecure
#d-i passwd/user-password-again password insecure
# or encrypted using a crypt(3) hash.
#d-i passwd/user-password-crypted password [crypt(3) hash]
# Create the first user with the specified UID instead of the default.
#d-i passwd/user-uid string 1010

# To create a normal user account.
# d-i passwd/user-fullname string User Fullname
# d-i passwd/username string unspecified-user
# Normal user's password, either in clear text
# d-i passwd/user-password password passw0rd
# d-i passwd/user-password-again password passw0rd
# or encrypted using a crypt(3) hash.
#d-i passwd/user-password-crypted password [crypt(3) hash]
# Create the first user with the specified UID instead of the default.
#d-i passwd/user-uid string 1010


# The user account will be added to some standard initial groups. To
# override that, use this.
#d-i passwd/user-default-groups string audio cdrom video

### Clock and time zone setup
# Controls whether or not the hardware clock is set to UTC.
d-i clock-setup/utc boolean true

# You may set this to any valid setting for $TZ; see the contents of
# /usr/share/zoneinfo/ for valid values.
d-i time/zone string US/Eastern

# Controls whether to use NTP to set the clock during the install
d-i clock-setup/ntp boolean true
# NTP server to use. The default is almost always fine here.
#d-i clock-setup/ntp-server string ntp.example.com

### Partitioning
## Partitioning example
# If the system has free space you can choose to only partition that space.
# This is only honoured if partman-auto/method (below) is not set.
#d-i partman-auto/init_automatically_partition select biggest_free

# Alternatively, you may specify a disk to partition. If the system has only
# one disk the installer will default to using that, but otherwise the device
# name must be given in traditional, non-devfs format (so e.g. /dev/sda
# and not e.g. /dev/discs/disc0/disc).
# For example, to use the first SCSI/SATA hard disk:
#d-i partman-auto/disk string /dev/sda
# In addition, you'll need to specify the method to use.
# The presently available methods are:
# - regular: use the usual partition types for your architecture
# - lvm: use LVM to partition the disk
# - crypto: use LVM within an encrypted partition
d-i partman-auto/method string regular
d-i partman-auto/disk string /dev/vda

# You can define the amount of space that will be used for the LVM volume
# group. It can either be a size with its unit (eg. 20 GB), a percentage of
# free space or the 'max' keyword.
#d-i partman-auto-lvm/guided_size string max

# If one of the disks that are going to be automatically partitioned
# contains an old LVM configuration, the user will normally receive a
# warning. This can be preseeded away...
d-i partman-lvm/device_remove_lvm boolean true
# The same applies to pre-existing software RAID array:
d-i partman-md/device_remove_md boolean true
# And the same goes for the confirmation to write the lvm partitions.
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

# You can choose one of the three predefined partitioning recipes:
# - atomic: all files in one partition
# - home: separate /home partition
# - multi: separate /home, /var, and /tmp partitions
# d-i partman-auto/choose_recipe select atomic

# Or provide a recipe of your own...
# If you have a way to get a recipe file into the d-i environment, you can
# just point at it.
#d-i partman-auto/expert_recipe_file string /hd-media/recipe

# If not, you can put an entire recipe into the preconfiguration file in one
# (logical) line. This example creates a small /boot partition, suitable
# swap, and uses the rest of the space for the root partition:

d-i partman-auto/expert_recipe string
 boot-root ::
 500 10000 -1 ext4
 $primary{ } $bootable{ }
 method{ format } format{ }
 use_filesystem{ } filesystem{ ext4 }
 mountpoint{ / }
 .
 128 10000 1024 linux-swap
 $primary{ }
 method{ swap } format{ }
 .
 2048 0 2048 ext4
 $primary{ }
 method{ format } format{ }
 use_filesystem{ } filesystem{ ext4 }
 mountpoint{ /var/log }
 .

# The full recipe format is documented in the file partman-auto-recipe.txt
# included in the 'debian-installer' package or available from D-I source
# repository. This also documents how to specify settings such as file
# system labels, volume group names and which physical devices to include
# in a volume group.

# This makes partman automatically partition without confirmation, provided
# that you told it what to do using one of the methods above.
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# When disk encryption is enabled, skip wiping the partitions beforehand.
#d-i partman-auto-crypto/erase_disks boolean false


# This makes partman automatically partition without confirmation.
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

## Controlling how partitions are mounted
# The default is to mount by UUID, but you can also choose "traditional" to
# use traditional device names, or "label" to try filesystem labels before
# falling back to UUIDs.
#d-i partman/mount_style select uuid

### Base system installation
# Configure APT to not install recommended packages by default. Use of this
# option can result in an incomplete system and should only be used by very
# experienced users.
#d-i base-installer/install-recommends boolean false

# The kernel image (meta) package to be installed; "none" can be used if no
# kernel is to be installed.
#d-i base-installer/kernel/image string linux-image-686

### Apt setup
# You can choose to install non-free and contrib software.
#d-i apt-setup/non-free boolean true
#d-i apt-setup/contrib boolean true
# Uncomment this if you don't want to use a network mirror.
#d-i apt-setup/use_mirror boolean false
d-i apt-setup/use_mirror boolean true
# Select which update services to use; define the mirrors to be used.
# Values shown below are the normal defaults.
#d-i apt-setup/services-select multiselect security, updates
#d-i apt-setup/security_host string security.debian.org

# Additional repositories, local[0-9] available
#d-i apt-setup/local0/repository string
# http://local.server/debian stable main
#d-i apt-setup/local0/comment string local server
# Enable deb-src lines
#d-i apt-setup/local0/source boolean true
# URL to the public key of the local repository; you must provide a key or
# apt will complain about the unauthenticated repository and so the
# sources.list line will be left commented out
#d-i apt-setup/local0/key string http://local.server/key

# By default the installer requires that repositories be authenticated
# using a known gpg key. This setting can be used to disable that
# authentication. Warning: Insecure, not recommended.
#d-i debian-installer/allow_unauthenticated boolean true

# Uncomment this to add multiarch configuration for i386
#d-i apt-setup/multiarch string i386

apt-cdrom-setup apt-setup/cdrom/set-first false
apt-cdrom-setup apt-setup/disable-cdrom-entries true


### Package selection
#tasksel tasksel/first multiselect standard, web-server, kde-desktop
tasksel tasksel/first multiselect standard, ssh-server

# Individual additional packages to install
#d-i pkgsel/include string openssh-server build-essential
d-i pkgsel/include string python-apt sudo

# Whether to upgrade packages after debootstrap.
# Allowed values: none, safe-upgrade, full-upgrade
#d-i pkgsel/upgrade select none
d-i pkgsel/upgrade select full-upgrade

# Some versions of the installer can report back on what software you have
# installed, and what software you use. The default is not to report back,
# but sending reports helps the project determine what software is most
# popular and include it on CDs.
#popularity-contest popularity-contest/participate boolean false
popularity-contest popularity-contest/participate boolean true

### Boot loader installation
# Grub is the default boot loader (for x86). If you want lilo installed
# instead, uncomment this:
#d-i grub-installer/skip boolean true
d-i grub-installer/skip boolean true
# To also skip installing lilo, and install no bootloader, uncomment this
# too:
d-i lilo-installer/skip boolean true


# This is fairly safe to set, it makes grub install automatically to the MBR
# if no other operating system is detected on the machine.
d-i grub-installer/only_debian boolean false

# This one makes grub-installer install to the MBR if it also finds some other
# OS, which is less safe as it might not be able to boot that other OS.
d-i grub-installer/with_other_os boolean false

# Due notably to potential USB sticks, the location of the MBR can not be
# determined safely in general, so this needs to be specified:
#d-i grub-installer/bootdev string /dev/sda
# To install to the first device (assuming it is not a USB stick):
#d-i grub-installer/bootdev string default
d-i grub-installer/bootdev string default

# Alternatively, if you want to install to a location other than the mbr,
# uncomment and edit these lines:
#d-i grub-installer/only_debian boolean false
#d-i grub-installer/with_other_os boolean false
#d-i grub-installer/bootdev string (hd0,1)
# To install grub to multiple disks:
#d-i grub-installer/bootdev string (hd0,1) (hd1,1) (hd2,1)

# Optional password for grub, either in clear text
#d-i grub-installer/password password r00tme
#d-i grub-installer/password-again password r00tme
# or encrypted using an MD5 hash, see grub-md5-crypt(8).
#d-i grub-installer/password-crypted password [MD5 hash]

nobootloader nobootloader/confirmation_powerpc_pasemi note
nobootloader nobootloader/confirmation_powerpc_chrp_pegasos note
nobootloader nobootloader/confirmation_common note
nobootloader nobootloader/mounterr note

# Use the following option to add additional boot parameters for the
# installed system (if supported by the bootloader installer).
# Note: options passed to the installer will be added automatically.
#d-i debian-installer/add-kernel-opts string nousb

### Finishing up the installation
# During installations from serial console, the regular virtual consoles
# (VT1-VT6) are normally disabled in /etc/inittab. Uncomment the next
# line to prevent this.
#d-i finish-install/keep-consoles boolean true

# Avoid that last message about the install being complete.
d-i finish-install/reboot_in_progress note

# This will prevent the installer from ejecting the CD during the reboot,
# which is useful in some situations.
#d-i cdrom-detect/eject boolean false
d-i cdrom-detect/eject boolean true

# This is how to make the installer shutdown when finished, but not
# reboot into the installed system.
#d-i debian-installer/exit/halt boolean true
# This will power off the machine instead of just halting it.
#d-i debian-installer/exit/poweroff boolean true

### Preseeding other packages
# Depending on what software you choose to install, or if things go wrong
# during the installation process, it's possible that other questions may
# be asked. You can preseed those too, of course. To get a list of every
# possible question that could be asked during an install, do an
# installation, and then run these commands:
# debconf-get-selections --installer > file
# debconf-get-selections >> file

#### Advanced options
### Running custom commands during the installation
# d-i preseeding is inherently not secure. Nothing in the installer checks
# for attempts at buffer overflows or other exploits of the values of a
# preconfiguration file like this one. Only use preconfiguration files from
# trusted locations! To drive that home, and because it's generally useful,
# here's a way to run any shell command you'd like inside the installer,
# automatically.

# This first command is run as early as possible, just after
# preseeding is read.
#d-i preseed/early_command string anna-install some-udeb
# This command is run immediately before the partitioner starts. It may be
# useful to apply dynamic partitioner preseeding that depends on the state
# of the disks (which may not be visible when preseed/early_command runs).
#d-i partman/early_command
# string debconf-set partman-auto/disk "$(list-devices disk | head -n1)"
# This command is run just before the install finishes, but when there is
# still a usable /target directory. You can chroot to /target and use it
# directly, or use the apt-install and in-target commands to easily install
# packages and run commands in the target system.
#d-i preseed/late_command string apt-install zsh; in-target chsh -s /bin/zsh
```

#### Packer Template

A packer JSON template such as the following named qemu-iso-armhf-no-efi-packer-template.json:

```json
{
    "variables": {
        "accelerator": "none",
        "build_time": "{{isotime "2006-01-02-15-04"}}",
        "domain": "",
        "hostname": "",
        "iso_checksum": "",
        "iso_checksum_type": "sha512",
        "iso_src_url_prefix": "",
        "iso_name": "",
        "machine_type": "virt",
        "memory_size": "1024",
        "os_disk_size": "8192",
        "output_compression": "true",
        "output_format": "qcow2",
        "vm_name_suffix": "-armhf.qcow2"
    },
    "builders": [
        {
            "type": "qemu",
            "accelerator": "{{ user `accelerator` }}",
            "cdrom_interface": "virtio-scsi",
            "communicator": "none",
            "cpus": 4,
            "disable_vnc": true,
            "disk_compression":"{{ user `output_compression` }}",
            "disk_size": "{{ user `os_disk_size` }}",
            "headless": true,
            "http_directory": "./preseed-dir",
            "format": "{{ user `output_format` }}",
            "iso_checksum": "{{ user `iso_checksum_type` }}:{{ user `iso_checksum` }}",
            "iso_url": "{{ user `iso_src_url_prefix` }}/{{ user `iso_name` }}",
            "machine_type": "{{ user `machine_type` }}",
            "memory": "{{ user `memory_size` }}",
            "net_device": "virtio-net-pci",
            "output_directory": "output/preseeded-armhf-no-efi-image-{{ user `hostname` }}-{{user `build_time`}}",
            "qemuargs": [
                [ "-display", "none" ],
                [ "-kernel", "{{ user `armhf_kernel` }}" ],
                [ "-initrd", "{{ user `armhf_initrd` }}" ],
                [ "-boot", "menu=off,order=dc,strict=on" ],
                [ "-serial", "mon:pty" ],
                [ "-no-reboot", null ],
                [ "-append", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed-arm-no-efi.cfg debian-installer/locale=en_CA.UTF-8 keyboard-configuration/xkb-keymap=us netcfg/get_hostname={{ user `hostname` }} netcfg/get_domain={{ user `domain` }} fb=false debconf/frontend=noninteractive preseed/late_command="wget -O - http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_default_late_command.sh | /bin/sh -s {{ .HTTPIP }} {{ .HTTPPort }} " "
                ]
            ],
            "qemu_binary": "qemu-system-arm",
            "shutdown_timeout": "2h30m",
            "use_backing_file": false,
            "vm_name": "{{ user `hostname` }}{{ user `vm_name_suffix` }}"
        }
    ]
}
```

#### Provisioning Script

A file named preseed_default_late_command.sh such as the following in the preseed-dir subdirectory:

```shell
#!/bin/sh

set -e

wget -O /target/etc/ssh/sshd_config http://${1}:${2}/sshd_config_buster
sed -i -e '1,$s/^(deb cdrom.*)/#1/' /target/etc/apt/sources.list

exit 0
```

#### A Provisioning SSH Server Config

A file named ssh_config_buster such as the following in the preseed-dir subdirectory:

```conf
# $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file. See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented. Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunnelled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication. Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem sftp /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
# X11Forwarding no
# AllowTcpForwarding no
# PermitTTY no
# ForceCommand cvs server
```

#### A Packer ‘var-file’

A packer ‘var-file’ (JSON) such as the following named
preseed-image-armhf-debian-10-var-file.json

```json
{
    "accelerator": "tcg",
    "armhf_kernel": "/home/user/Downloads/armhf-debian-10.6-buster-vmlinuz",
    "armhf_initrd": "/home/user/Downloads/armhf-debian-10.6-buster-initrd.gz",
    "domain": "example.net",
    "hostname": "preseed-image",
    "iso_checksum": "d0ca0c307fb86499748dee06ca1a2c8a2df1d574b98c14f605d8333eadac7e9f74d8d6a940f1fe34946ce91e4f73189bd1714176860382e14d1fed8483c2f6a6",
    "iso_checksum_type": "sha512",
    "iso_src_url_prefix": "file:///home/user/Downloads/",
    "iso_name": "debian-10.6.0-armhf-xfce-CD-1.iso",
    "machine_type": "virt-2.12,gic-version=2",
    "memory_size": "2048",
    "os_disk_size": "8192",
    "output_compression": "true",
    "output_format": "qcow2",
    "vm_name_suffix": "-armhf-no-efi-buster-packer.qcow2"
}
```

#### Optional: A serial terminal

If you want to watch the progress of the install you will need a serial terminal program
that works with a Linux pty as the serial input/output. picocom is a good choice.

## Execute Packer Command

1. Execute

   ```bash
   PACKER_LOG=1 packer build -var-file preseed-image-armhf-debian-10-var-file.json qemu-iso-armhf-no-efi-packer-template.json
   ```

2. The packer command while take a **long** time (probably over an hour and a half). To watch the progress point your serial terminal program at the PTY device with baud rate 115200, pointed to by the line Qemu stdout: char device redirected to /dev/pts/xin the packer output. ‘x’ will be a number. For example ``picocom -b 115200 /dev/pts/3`` if x was 3.

## Extract the Kernel and Initramfs (vmlinuz and initrd.img)

1. Change to the output directory containing the generated image.
2. Execute ``guestfish -i -a <name-of-image-file>``
3. Execute ``ls /boot`` to find the names of the newest vmlinuz and initrd.img (you don’t want the plain vmlinuz and initrd.img because they are just symlinks).
4. Execute

   ```bash
   copy-out /boot/vmlinuz-x.x.x-x-armmp-lpae /boot/initrd.img-x.x.x-x-armmp-lpae ./
   ```

5. Execute exit
6. Copy the vmlinuz an initrd.img files to a directory that you can use with the subsequent
Packer provisioning step. For this guide we use /home/user/Documents/Artifacts.

Next: [Use the Image (and boot files)](use-the-image.md)
