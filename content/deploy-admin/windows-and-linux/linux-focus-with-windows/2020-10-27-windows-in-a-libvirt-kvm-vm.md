---
slug: windows-in-a-libvirt-kvm-vm
aliases:
    - /2020/10/27/windows-in-a-libvirt-kvm-vm/
    - /post/windows-in-a-libvirt-kvm-vm/
    - /deploy-admin/windows-in-a-libvirt-kvm-vm/
    - /windows-in-a-libvirt-kvm-vm/
    - /docs/sysadmin-devops/windows-and-linux/windows-in-a-libvirt-kvm-vm/
    - /sysadmin-devops/windows-and-linux/windows-in-a-libvirt-kvm-vm/
    - /docs/deploy-admin/windows-and-linux/windows-in-a-libvirt-kvm-vm/
title: Windows in a Libvirt KVM VM
date: '2020-10-27T12:44:00+00:00'
publishDate: '2020-10-27T12:44:00+00:00'
tags:
- linux
- sysadmin-devops
- virtualization
- windows
- windows-and-linux
author: Daniel F. Dickinson
description: "These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows in a Libvirt/KVM VM."
summary: "These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows in a Libvirt/KVM VM."
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows in a Libvirt/KVM VM. I also have [Notes on Windows and Linux hybrid environment in a physical machine](2020-08-20-windows-and-linux-in-one.md).

It should be noted that while this guide takes a more complicated approach to setting up the virtual machine, it should result in better performance when using it because we configure the network and hard drive as 'VirtIO' (paravirtualized) devices instead of emulated devices.

## See the common notes first

I recommend reading [Common setup for Windows and Linux systems](2021-04-24-common-windows-and-linux.md) first (there will be points at which you are referred back to this page) and use this page for the parts specific to Windows in a Libvirt/KVM VM.

## Installation notes

Use at least Windows 10 Pro Version 2004, with Version 20H2 preferred.
Windows 10 Home might work for some of this, but not all features are available.

## Setting up the virtual machine on a Linux host

**NOTE** This guide doesn't use bleeding edge setting. Instead we stick (Linux side) to stable and tested technologies that, except bug fixes, performance improvements, and generally getting better over time, have been available in Linux for at least five years.

That means, for example, we don't use a UEFI VM (for that item there is no real point, quite yet, as the SecureBoot/certificate chain for WHQL-certified VirtIO drivers for Windows isn't (yet) available outside of a paid RedHat subscription — it appears Ubuntu has a Windows Server edition version of the VirtIO drivers that use that technology, but I am not aware of the same for Windows 10).

### Install Virtual Machine Manager and virt-viewer on your Linux host

1. For example, on Debian/Ubuntu/Linux Mint issue the command:
   `sudo apt-get install libvirt-daemon virt-clients virt-manager virt-viewer`
2. Add an 'isolated' network to use for communication between the Linux host and guests (the default install
   already adds a 'NAT' network named `default` for communicating to other hosts).
   1. Launch `Virtual Machine Manager`
   2. Double-click on the line labelled `QEMU/KVM`:…
   3. Click on the `Virtual Networks` Tab
   4. Click on the `+` icon (aka `Add Network`)
   5. Give the network a name.
   6. Chose Mode: `Isolated.`
   7. Configure the networking information.
   8. Click `Finish`.
3. If you want to be able to allow network traffic from other hosts on the network or internet to the virtual
   machine you will need to do some searching and reading about Linux networking — that is out of scope for
   this article.

### Download and install Windows and drivers

We're doing this a slightly harder way (using virtio drivers during install) that give better cpu, disk, and
network performance.

#### Download the necessary CD images

1. Make sure you have a Windows 10 Product Key to verify your right to use Windows 10.
2. Download the [most recent Windows 10 Pro release](https://www.microsoft.com/en-us/software-download/windows10ISO), which is 20H2 (October 2020 Release) as of this writing. For this guide you definitely want the English 64-bit version.
   1. This will download a file named `Win10_20H2_English_x64.iso`
   2. I recommend you also click on 'Verify your download` on the microsoft download page, and find the 'hash'
     the 'English 64-bit' version.
   3. Once the ISO is downloaded, open a terminal.
      1. `cd ~/Downloads`
      2. `sha256sum Win10_20H2_English_x64.iso`
      3. The output should match the hash from the site above (case doesn't matter).
      4. If the output does not match the given hash, the download failed; try again.
3. Download the [Latest stable KVM VirtIO drivers ISO from the Fedora Project](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.208-1/virtio-win-0.1.208.iso)
4. Copy both `.iso` files to `/var/lib/libvirt/images`. You will need to do the copy as root
  (e.g. using `sudo`).
5. Alternatively, or if Libvirt is running on a different Linux machine than the one with the `.iso` files:
   1. `ls -al '*.iso'` and make note of the file sizes of the ISO you want to use with libvirt.
   2. `virsh -c <URI-to-libvirt-host> vol-create-as --pool default --allocation <size-of-file-from-ls> --capacity <size-of-file-from-ls> --format raw --name <name-of-ISO>`
   3. `virsh -c <URI-to-libvirt-host> vol-upload --pool default --vol <name-of-ISO> --file <path-to-and-ISO-name>`

* Example URIs for libvirt hosts include:
  * For a local qemu/kvm libvirt: `qemu:///system`
  * For accessing qemu/kvm libvirt via SSH: `qemu+ssh://user@host/system`

#### Initial steps for creating the Windows virtual machine

Using Virtual Machine Manager create a virtual machine for Windows

1. In VMM (Virtual Machine Manager) select the icon in the top left ('Create a new virtual machine')
2. Choose _Local Install media (ISO image or CDROM)_
3. Verify 'Architecture options|Architecture' is _x86_64_
4. Select 'Forward'
5. Browse for the Windows ISO
6. For 'Choose the operating system you are installing' enter/select 'Microsoft Windows 10'
7. Select 'Forward'
8. If you have enough memory, give the virtual machine 8192 MB (8 GB) of memory, otherwise use
  the defaults (minimum 4096 MB)
9. Recommending giving at least two cpus, but four would be better.
10. Select 'Forward'
11. Set the size of Hard Disk to give the Windows Virtual Machine.  I recommend at least 80 GB, although
   according to Microsoft the VMM default of 40 GB ought to be 'enough'.
12. Select 'Forward'
13. Give the virtual machine a name for VMM purposes (this is different than the Windows hostname).
14. Make sure `Customize configuration before install` is checked.
15. Select 'Finish'.

#### Finalize the configuration of the Windows virtual machine

1. In Overview, make sure the virtual machine has the name you want.
2. Also in overview, use a Q35 BIOS virtual machine
3. Select `SATA Disk 1`
   1. Under `Advanced Options` change `Disk bus` to `VirtIO` and click `Apply`
   2. `SATA Disk 1` will become `VirtIO Disk 1`
4. Select `NIC:xx:xx:xx`
   1. Change `Device model` to `virtio`
5. Select `Add Hardware`
   1. Choose `Select or create custom storage`
   2. Select `Manage...` and select the VirtIO driver ISO
   3. Change `Device type` to `CDROM device`
   4. Select `Finish`
6. Select 'Add Hardware`
   1. Choose `Network`
   2. Change `Network source` to the isolated network you created
   3. Change `Device model` to `virtio`
   4. Select `Finish`
7. Select `Add Hardware`
   1. Choose `Channel`
   2. For `Name` select `org.qemu.guest_agent.0`
   3. Select `Finish`
8. Select `Add Hardware`
   1. Choose `Channel`
   2. For `Name` select `org.spice-space.webdav.0`
   3. Select `Finish`
9. Select `Add Hardware`
   1. Choose `RNG`
   2. Select `Finish`
10. Select `Begin Installation`

### The parts that come with your Windows license and/or base VM requirements

#### The Windows install bootstrap (early install)

1. A VMM graphical console showing the Windows boot process and then installer screen will open.
2. Select your language and other preferences and then click 'Next'.
3. Click 'Install Now'
4. Enter your Windows Product Key and Click 'Next'
5. As if you had a real choice (not using Windows is unrealistic for most in today's world);
   check 'I accept the license terms'
6. Select 'Install Windows'
7. Install the VirtIO drivers we need
   1. Select 'Load Driver'
   2. Click `Browse`
   3. Select the virtio driver ISO (probably drive E:)
   4. Double-click on `NetKVM`, then `w10`, then `amd64`, then click `OK`
   5. The VirtIO Ethernet Driver should be selected, so Click 'Next'
   6. Select 'Load Driver'
   7. Click `Browse`
   8. Select the virtio driver ISO (probably drive E:)
   9. Double-click on `viostor`, then `w10`, then `amd64`, then click `OK`
   10. The VirtIO SCSI Driver should be selected, so Click 'Next'
8. `Drive 0 Unallocated Space` should be selected, so click 'Next'
9. Wait while Windows installs the base system.
10. Reboot (will occur automatically after a bit).

#### Finishing the base Windows install

After the initial installation phase the Windows install will reboot at which point you will do the usual Windows 10 Pro first boot procedure. This article won't cover those steps as there are many thorough guides available.

* When prompted about whether to make this computer publicly visible to other computers and devices on the   network, it is safe to say 'yes' because the network is actually a local (to the Linux host) network that is   has a NAT between the Windows VM and anything outside the Linux host. (It is still recommended to add a   firewall to your Linux host, but that is outside the scope of this article). If you don't plan on using Windows File Sharing from the virtual machine to other hosts you can safely (and and it's safer) to say 'no' here.

* If you want to be able to access Windows file sharing resources on your local network outside the Linux host   from the Windows Virtual Machine you will have to make this network a 'Private' (trusted) network so that File and Print sharing will work on that network for the Windows VM. For the prompt mentioned above, that means choosing 'Yes'.

* If you will be wanting other devices to access network resources on the Windows VM you will need to do some additional reading / research to learn how to set up the network to allow this. Such a configuration is beyond the scope of this article.

#### Install the QEMU Guest Agent and Spice guest tools

1. In _File Explorer_ open the KVM VirtIO drivers CD.
2. Double-click `virtio-win-guest-tools` and follow the prompts.

#### Update with Windows Update

* Make sure your machine is activated and fully up to date with _Windows Update_.
* If you wish, configure 'Advanced Options' and 'Delivery Optimization' of 'Windows Update'.

#### Make the isolated (host-only) second network a 'private' network

We want the isolated second network we created to be used as a 'trusted' communications network between the VM and the host, which means we need to convince Windows to label it a 'Private' network.

1. In an 'Administrator' Powershell, issue the command `ipconfig` and make note of which 'Ethernet' adaptor is associated with which network (that is host-only vs. default/NAT network).
2. In the same powershell, issue `route print` and note which interface number is the 'host-only' network
3. Also note the IP address associated with the host-only network
4. In the same powershell, issue `route -P add 0.0.0.0 mask 0.0.0.0 <IP-address-of-host-only-network> metric 1500 if <interface-number-from-above>`

You should be prompted to allow other computers to see this host on this network which will likely be called 'Network 2'. Say yes — that makes this a private (trusted) network.

You can now exit the administrator powershell.

* If you want to verify which networks on the virtual machine are considered
  'Private', click on the network icon in the taskbar, and then select "Network & Internet Settings".
* On the left, select 'Ethernet', and click on each network listed there, in turn.
* When you select the network you should see the option to configure it as
  'Public' or 'Private'. 'Public' means the network is not trusted and uses a more restrictive firewall.

#### Tweak according to common Windows and Linux setup

* [Configure language and regional settings as appropriate](2021-04-24-common-windows-and-linux.md#configure-language-and-regional-settings-as-appropriate)
* [Tweak the base install (before adding any software or apps) and settings to your preferred base configuration(2021-04-24-common-windows-and-linux.md#fn:2)
* I also recommend creating a copy of your freshly installed virtual hard drive. (the virtual disk image on a typical Debian/Ubuntu system would be located in ``/var/lib/libvirt/images``) as well as the Libvirt configuration in ``/etc/libvirt``. It is presumed you know enough Linux, or can learn it elsewhere, to do this.

#### Configure 'Network and Sharing', if applicable

If you want to allow this virtual machine to access Windows file shares on hosts
on networks you have marked as 'Private' (trusted) networks you need to configure
'File and Printer Sharing'.

1. Open `Settings`
2. Select `Network & Internet`
3. Select `Network and Sharing Center`
4. Click on `Change advanced sharing settings`
5. Under the 'Private' section, 'File and printer sharing' subsection, select `Turn on file and printer sharing`
6. Under the 'Public' section, 'File and printer sharing' subsection, select `Turn off file and printer sharing`
7. The 'Network discovery` subsections are irrelevant because of the type of networking used in the configuration
   in this article. This VM can't discover hosts outside the Linux host, and hosts outside the Linux hosts can
   find this VM, even if the options are enabled.
8. Under `All networks`, `Password protected sharing` subsection, make sure `Turn on password protect sharing` is
   enabled.

#### Configure language and regional features as appropriate

See [language and region configuration in common docs](2021-04-24-common-windows-and-linux.md#configure-language-and-regional-settings-as-appropriate)

#### Configure 'For developers' in 'Upgrades & Security'

* You should go through these settings as many of them are useful to power
  users and developers – be careful though as there are often security implications to the options.  I certainly don't enable all the options.
* If you have enabled networking into the virtual machine, and you do allow 'Remote Desktop' I recommend altering the default firewall rule to be for 'Private' networks only, perhaps even only for your particular subnet.

#### Add Windows (system) features

Head back to [common setup for windows and linux systems](2021-04-24-common-windows-and-linux.md#add-windows-system-features), you shouldn't need to come back to this page.

### The rest, as suits your needs and preferences

The rest is about learning what makes for a comfortable environment for you.  I
personally tend to get annoyed with 'opinionated' or 'perfect' setup guides, and
am trying to create more flexible set of suggestions that can easily be adapted
to suit _you_.
