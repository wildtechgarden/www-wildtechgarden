---
slug: windows-and-linux-in-one
aliases:
    - /2020/08/20/windows-and-linux-in-one/
    - /post/windows-and-linux-in-one/
    - /deploy-admin/windows-and-linux-in-one/
    - /windows-and-linux-in-one/
    - /docs/sysadmin-devops/windows-and-linux/windows-and-linux-in-one/
    - /sysadmin-devops/windows-and-linux/windows-and-linux-in-one/
    - /blog/windows-and-linux-in-one/
    - /docs/deploy-admin/windows-and-linux/windows-and-linux-in-one/
author: Daniel F. Dickinson
date: '2020-08-21T01:40:00+00:00'
publishDate: '2020-08-21T01:40:00+00:00'
tags:
- linux
- sysadmin-devops
- windows
- windows-and-linux
title: Windows and Linux in one
description: "These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows on a physical machine"
summary: "These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows on a physical machine"
---

{{< details-toc >}}

## Preface

These are notes on creating a Windows and Linux hybrid environment, specifically when running Windows on a physical machine. I also have [Notes on Windows and Linux hybrid environment in a Libvirt/KVM VM](2020-10-27-windows-in-a-libvirt-kvm-vm.md).

## See the common notes first

I recommend reading [Common setup for Windows and Linux systems](2021-04-24-common-windows-and-linux.md) first (there will be points at which you are referred back to this page) and use this page for the parts specific to Windows on Physical Hardware.

## Installation notes

Use at least Windows 10 Pro Version 2004, with Version 20H2 preferred.
Windows 10 Home might work for some of this, but not all features are available.

### Configure 'For developers' in 'Upgrades & Security'

* If you do allow 'Remote Desktop' I recommend altering the default firewall
  rule to be for 'Private' networks only, perhaps even only for your particular
  subnet (assuming you aren't using the default for your router, since if you are
  that limitation isn't particularly meaningful).
* One thing I prefer over enabling 'Change settings so that PC never goes to sleep when plugged in', is to have 'Wake on Lan' enabled, and to install the `MagicPacket` app from the 'Windows Store' (on the host from which you will be remoting, not the host you are installing),  `MagicPacket` is a nice free app that allows you to save the information to wake a particular host using the Wake on Lan 'Magic Packet' option (with or with out a password), which avoids the host waking up on random network traffic.

### Add Windows (system) features

Head back to [common setup for windows and linux systems](2021-04-24-common-windows-and-linux.md#add-windows-system-features), you shouldn't need to come back to this page.

### The rest, as suits your needs and preferences

The rest is about learning what makes for a comfortable environment for you.  I
personally tend to get annoyed with 'opinionated' or 'perfect' setup guides, and
am trying to create more flexible set of suggestions that can easily be adapted
to suit _you_.
