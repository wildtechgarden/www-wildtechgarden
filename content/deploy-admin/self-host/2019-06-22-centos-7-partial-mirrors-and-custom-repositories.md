---
slug: centos-7-partial-mirrors-and-custom-repositories
aliases:
    - /2019/06/22/centos-7-partial-mirrors-and-custom-repositories/
    - /post/centos-7-partial-mirrors-and-custom-repositories/
    - /deploy-admin/centos-7-partial-mirrors-and-custom-repositories/
    - /centos-7-partial-mirrors-and-custom-repositories/
    - /docs/sysadmin-devops/self-host/centos-7-partial-mirrors-and-custom-repositories/
    - /sysadmin-devops/self-host/centos-7-partial-mirrors-and-custom-repositories/
    - /docs/deploy-admin/self-host/centos-7-partial-mirrors-and-custom-repositories/
author: Daniel F. Dickinson
date: '2019-06-22T23:21:00+00:00'
publishDate: '2019-06-22T23:21:00+00:00'
summary: "ARCHIVED: Often you don't need a full mirror of CentOS and/or EPEL, so we give a working example of a partial mirror and custom repository setup."
description: "ARCHIVED: Often you don't need a full mirror of CentOS and/or EPEL, so we give a working example of a partial mirror and custom repository setup."
tags:
- archived
- centos
- linux
- package-management
- security
- self-host
- sysadmin-devops
title: "CentOS 7 partial mirrors/custom repos"
toc: true
weight: 80000
---

## ARCHIVED

CentOS 7 is getting rather old, and CentOS has changed delivery models in ways that change where it is useful.

This document is archived and may be out of date or inaccurate.

## Overview

Often you don't need a full mirror of CentOS and/or only want a small set
of packages from other repositories such as EPEL, so to save bandwidth, space, and
time we give a working example of a partial mirror and custom repository setup.

## Partial mirroring example

*Note that we could use this technique for any mirror which offers rsync
mirroring.*

### What we want to mirror from main mirrors

#### Desired subsections of main repo

* x86_64 only
* base (aka os)
* extras
* updates
* openstack Stein related packages
  * openstack-stein repo
  * ceph-luminous repo
  * kvm-common repo

#### Corresponding directory structure

```text
/os/x86_64/Packages/
/os/x86_64/repodata/
/extras/x6_64/Packages/
/extras/x86_64/repodata/
/updates/x86_64/Packages/
/updates/x86_64/repodata/
/cloud/x86_64/openstack-stein/
/storage/x86_64/ceph-luminous/
/virt/x86_64/kvm-common/
```

### Preparation

#### Create mirror dir

* In a directory which will be served by your web server of choice
(preferably at the root of your served directories, or rewritten to
appear to be):
* *NB: as of this writing; for a future point release substitute the
appropriate version number*
* ``mkdir -p /var/lib/www/html/centos/7.6.1810/os``

#### Start with contents of install media

* mount or otherwise gain access to contents of your official CentOS
install media, e.g. on /mnt
* ``rsync -ar /mnt/ /var/lib/www/html/centos/7.6.1810/os/``
* Assuming you're already serving /var/lib/www/html as the
webserver root and have directory listings on, browsing to
``http://centos/7.6.1810/os/`` should show the contents of your
install media and ``http://centos/7.6.1810/os/Packages/`` should have
the base packages for CentOS 7.

#### Find a nearby (network-wise) Rsync mirror

* Visit the [Official List of CentOS
Mirrors](https://www.centos.org/download/mirrors/ "List of CentOS Mirrors"),
and find and a mirror close to you (network-wise) which provides an
rsync address and record. For instance:
``rsync://centos.mirror.rafal.ca/CentOS/``.

### Rsync script for mirroring

### An interactive Rsync command

```sh
rsync --info=progress2 -DrltK --inplace --safe-links --delete-after --bwlimit=4000 \
 --include='os/' \
 --include='extras/' \
 --include='updates/' \
 --include='cloud/' \
 --include='storage/' \
 --include='virt/' \
 --include='os/x86\_64/' \
 --include='cloud/x86_64/' \
 --include='storage/x86_64/' \
 --include='virt/x86_64/' \
 --include='os/x86-64/Packages/' \
 --include='os/x86_64/Packages/***' \
 --include='os/x86_64/repodata/' \
 --include 'os/x86_64/repodata/***' \
 --include='extras/x86_64/' \
 --include='extras/x86_64/*' \
 --include='extras/x86_64/Packages/***' \
 --include='extras/x86_64/repodata/**' \
 --include='updates/x86_64/' \
 --include='updates/x86_64/Packages/' \
 --include='updates/x86_64/Packages/***' \
 --include='updates/x86_64/repodata/' \
 --include='updates/x86_64/repodata/***' \
 --include='cloud/x86_64/openstack-stein/*' \
 --include='cloud/x86_64/openstack-stein/***' \
 --include='storage/x86_64/ceph-luminous/***' \
 --include='virt/x86_64/kvm-common/***' \
 --exclude='*' \
 rsync://centos.mirror.rafal.ca/CentOS/7.6.1810/ /var/lib/www/html/centos/7.6.1810/
```

#### A full script

```sh
#/bin/sh

set -e

if [ -f /var/lock/subsys/centos\_rsync\_updates ]; then
 echo "Updates via rsync already running."
 exit 0
fi

if [ -d /var/lib/www/html/centos/7.6.1810 ]; then
 mkdir -p /var/lock/subsys
 touch /var/lock/subsys/centos\_rsync\_updates
 rsync -q -DrltK --inplace --safe-links --delete-after --bwlimit=4000 \
 --include='os/' \
 --include='extras/' \
 --include='updates/' \
 --include='cloud/' \
 --include='storage/' \
 --include='virt/' \
 --include='os/x86_64/' \
 --include='cloud/x86_64/' \
 --include='storage/x86_64/' \
 --include='virt/x86_64/' \
 --include='os/x86-64/Packages/' \
 --include='os/x86_64/Packages/***' \
 --include='os/x86_64/repodata/' \
 --include 'os/x86_64/repodata/***' \
 --include='extras/x86_64/' \
 --include='extras/x86_64/*' \
 --include='extras/x86_64/Packages/***' \
 --include='extras/x86_64/repodata/**' \
 --include='updates/x86_64/' \
 --include='updates/x86_64/Packages/' \
 --include='updates/x86_64/Packages/***' \
 --include='updates/x86_64/repodata/' \
 --include='updates/x86_64/repodata/***' \
 --include='cloud/x86_64/openstack-stein/*' \
 --include='cloud/x86_64/openstack-stein/***' \
 --include='storage/x86_64/ceph-luminous/***' \
 --include='virt/x86\_64/kvm-common/***' \
 --exclude='*' \
 rsync://centos.mirror.rafal.ca/CentOS/7.6.1810/ /var/lib/www/html/centos/7.6.1810/
rm -f /var/lock/subsys/centos\_rsync\_updates
exit 0
else
echo "Target directory /var/lib/www/html/centos/7.6.1810 not present"
exit 1
fi
```

## Custom repositories

* This technique requires that the host downloading the packages be
the same distribution, version, and architecture as the intended
repository packages.
* For this article we assume the actions are taking place on a host of
the proper distribution, version, and architecture, and that the
repositories from which packages are to be downloaded are enabled.

### Selected packages we want to mirror from 'other' repositories

| Package   | Repository         |
| --------- | ------------------ |
| etckeeper | epel               |
| byobu     | epel               |
| logwatch  | epel               |
| restic    | COPR copart/restic |

### Use yumdownloader to create package cache

*Note that the following is intended for use in a cronjob and we don't
want normal usage messages to produce email. For interactive use you
don't need to redirect to /dev/null and can get some useful output.*

```sh
yumdownloader --destdir=/home/centos/centos-cshore-cache --resolve restic etckeeper byobu logwatch >/dev/null
```

### Create repo from package cache

We first copied the cache above to another dir to avoid conflicts during
cron usage, then (also not dropping output again).

```sh
( cd /home/centos/centos-custom-cache-repo && createrepo . ) >/dev/null
```

Optionally create a detached GnuPG signature from the repomd.xml that
will be in the output directory. Required if you want to require GnuPG
signature verification.

### Copy repo to your web server

```sh
rsync --delete-after -Dlrt /home/centos/centos-custom-cache-repo/ bootserver:/var/lib/www/html/centos-custom-repo/
```

## Sample .repo file for the above

-------------------------------

Note that this file skips GnuPG checks for the custom repo; it would be
better to sign the repomd.xml (with detached signature repomd.xml.asc
which would appear in the same directory) and distribute the GnuPG key
to target hosts.

```ini
[centos-core]
name=CentOS Core Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/os/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centos-extras]
name=CentOS Extras Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/extras/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centos-updates]
name=CentOS Updates Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/updates/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centos-openstack-stein]
name=CentOS OpenStack Stein Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/cloud/x86_64/openstack-stein/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud
exclude=sip,PyQt4

[centos-storage-ceph-luminous]
name=CentOS Ceph Luminous Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/storage/x86_64/ceph-luminous/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage

[centos-virt-kvm-common]
name=CentOS KVM Common Hosted Locally
baseurl=http://proxy.example.net/centos/7.6.1810/virt/x86_64/kvm-common/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization

[centos-cshore-cache]
name=CentOS - CShore's Cache
baseurl=http://proxy.example.net/centos-cshore-cache/
enabled=1
skip_if_unavailable=1
gpgcheck=0
```

## See also

* [CentOS Wiki HowTos/CreateLocalMirror](https://wiki.centos.org/HowTos/CreateLocalMirror "Link to CentOS Wiki page about create local mirrors and repositories.")
