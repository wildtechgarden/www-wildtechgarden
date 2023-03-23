---
slug: package-installation-and-updates-on-an-isolated-network
aliases:
- /2019/07/22/package-installation-and-updates-on-an-isolated-network/
- /post/package-installation-and-updates-on-an-isolated-network/
- /deploy-admin/package-installation-and-updates-on-an-isolated-network/
- /package-installation-and-updates-on-an-isolated-network/
- /docs/sysadmin-devops/self-host/package-installation-and-updates/on-an-isolated-network/
- /sysadmin-devops/self-host/package-installation-and-updates-on-an-isolated-network/
- /docs/deploy-admin/self-host/package-installation-and-updates-on-an-isolated-network/
author: Daniel F. Dickinson
date: '2019-07-22T23:20:00+00:00'
publishDate: '2019-07-22T23:20:00+00:00'
summary: For your self-hosted systems there are likely hosts you don't want internet-connected, but you still want to be able to do package installs and updates.
description: For your self-hosted systems there are likely hosts you don't want internet-connected, but you still want to be able to do package installs and updates.
tags:
- archived
- centos
- debian
- linux
- package-management
- security
- self-host
- sysadmin-devops
title: "Network isolation and package management"
toc: true
weight: 80000
---

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## Overview

For your self-hosted systems there are likely hosts you don't want exposed
to the wilds of 'The Internet', even for outgoing traffic, but you still want to
be able to do package updates. Here is how you do that using NGINX as a proxy on
a host on an isolated network and is also on an internet connected network.

## Prerequisites

* An isolated network (e.g. a network with no internet connectivity)
-- aka *isolated-net*.
* At least one host solely on the isolated network that you can
administer (e.g. through a console).
* An internet connected network (can be through a NAT router, the
important bit is that hosts on the network are free to go out to
hosts on the internet) -- aka *internet-net*.
* A host which as an interface both on *isolated-net* and on
*internet-net*. We'll call this host *proxy-host*.
* IP Forwarding is disabled on *proxy-host* (not a strict requirement,
but avoids the possibility of *proxy-host* leaking traffic between
*isolated-net* and *internet-net* accidentally.

## Method 1: Mirroring and/or creating package repositories on *proxy-host*

### Notes

* This is the most work, but is the more isolated option.
* It can be arranged to do the serving the repositories on the
*proxy-host* but the mirroring or repository creation on another
host, with the results copied to *proxy-host*. This gives quite a
high degree of isolation.
* We cover both types of repo here. Details of the highly isolated
configuration are left as an exercise for the reader.

### Mirroring

#### CentOS 7 package mirror

* See the [CentOS Wiki HowTos/CreateLocalMirror](https://wiki.centos.org/HowTos/CreateLocalMirror "Link to CentOS Wiki's 'CreateLocalMirror' page for information on create mirrors and repositories for Centos 6/7") page for basic information.
* For a more detailed example see [CentOS 7 partial mirrors and custom repositories page](2019-06-22-centos-7-partial-mirrors-and-custom-repositories.md)

#### Debian/Ubuntu package mirror

* See the [Debian Wiki
Debian/Repository/Setup](https://wiki.debian.org/DebianRepository/Setup "Link to DebianRepository/Setup -- the repository creation and mirroring table of contents for Debian and derivatives.")
page for many options and details.

### Target configuration

1. mkdir -p /etc/yum/pluginconf.d.disabled; mv /etc/yum/pluginconf.d/* /etc/yum/pluginconf.d/disabled
2. mkdir -p /etc/yum.repos.d.disabled; mv /etc/yum.repos.d/* /etc/yum.repos.d.disabled
3. Given a partial mirror and/or custom repository, use something like [CentOS 7 repo sample yum repo configuration files (a .repo file)](2019-06-22-centos-7-partial-mirrors-and-custom-repositories.md#sample-repo-file-for-the-above) which points to the server which is both has access to the internet and is connected to the isolated network.
4. Now you can yum install and yum upgrade from the local repository without hitting the internet from the host performing the yum command.

## Method 2: Proxy specific URL prefixes to a specific package mirror

### CentOS 7 packages via proxy

* E.g. In nginx proxy <http://proxy.example.net/centos> to
~~``http://centos.mirrorhost.net/centos``~~.

* To do so use an nginx.conf with a part such as:

  ```nginx
  location /centos {
  allow 192.168.22.0/24;
  allow fa3b:1452:2426:22::/64;
  deny all;
  autoindex off;
  resolver 192.168.22.1;
  proxy_pass http://centos.mirrorhost.net$uri$is\_args$args;
  }
  ```

  in the appropriate server section.
* Replace the existing .repo file sections (in /etc/yum.repos.d/*) with ones like:

  ```ini
  [centos-core]
  name=CentOS Core Hosted Locally
  baseurl=http://proxy.example.net/centos/7.6.1810/os/x86\_64/
  enabled=1
  skip_if_unavailable=1
  gpgcheck=1
  gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
  ```

### Debian and derivatives: packages via proxy

**EDIT: For a better solution see [apt cache for isolated networks](https://fabianlee.org/2018/02/11/ubuntu-a-centralized-apt-package-cache-using-apt-cacher-ng/)**

* E.g. In nginx proxy <http://proxy.example.net/debian> to
~~``http://debian.mirrorhost.net/debian``~~.

* To do so use an nginx.conf with a part such as:

```nginx
  location /debian {
    allow 192.168.22.0/24;
    allow fa3b:1452:2426:22::/64;
    deny all;
    autoindex off;
    resolver 192.168.22.1;
    proxy_pass http://debian.mirrorhost.net$uri$is\_args$args;
  }
```

  in the appropriate server section.

* And update the package repository file (in the above example, it's
/etc/apt/sources.list for a debian (or derivative) system) to
point to proxy.example.net instead of debian.mirrorhost.net (or
other mirror).
* E.g. deb <http://proxy.example.net/debian/> stretch main contrib non-free

### Other package managers

* The same general technique can be applied to most package managers.
As long as you can have a 'prefix' to the path part of the URL
(e.g. in this case /debian and can specify a specific mirror
(which becomes your proxy host, in this case proxy.example.net),
you can redirect the package traffic to host of your choices.
* For things like restic self-update, however, it doesn't work
because restic has <https://github.com> hard-coded as a download path,
and we can't intercept that without looking like a
Man-in-the-Middle attack. We probably don't want to 'fix' that
even if we could, since having 'random' binaries updating
themselves is probably a bad idea anyway. Instead we need to
implement some other release monitoring and update notification
method, and to manually update the third party package.
