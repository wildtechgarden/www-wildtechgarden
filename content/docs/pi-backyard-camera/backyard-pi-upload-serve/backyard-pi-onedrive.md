---
slug: backyard-pi-onedrive
aliases:
  - /post/pi-backyard-camera/backyard-pi-onedrive/
  - /deploy-admin/pi-backyard-camera/backyard-pi-onedrive/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-onedrive/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-upload-serve/backyard-pi-onedrive/
  - /backyard-pi-sub-pages/backyard-pi-onedrive/
title: "Backyard Pi OneDrive"
author:
date: 2021-09-23T01:55:44Z
publishDate: 2021-09-23T01:55:44Z
tags:
    - linux
    - raspberry-pi
    - self-host
description: Copying backyard camera videos and pictures to Microsoft OneDrive using rclone
summary: Copying backyard camera videos and pictures to a Microsoft OneDrive using rclone
---

{{< details-toc >}}

## Overview

* This article only discusses the rclone config.
* For the ``copymotion`` script below it is assumed that the directory from which the Microsoft OneDrive is configured to serve the files is ``/motion``.  You should adapt the script as appropriate if you configure the OneDrive to share a different directory for motion files.
* We further assume that the ``rclone`` 'remote' is called ``onedrive-motion`` for this server.

### Security

I don't recommend using this until rclone folks figure out how to reduce the level of permissions they need to get rclone to work. They've done it with other providers, but the current implementation for OneDrive (possibly due Microsoft not having more granular options when this rclone backend was written; in any event it will be discontinued soon and may not respond after sometime on June 2022 and in any event will not receive security or other fixes after that point) backend in rclone will soon stop working, and requires a scary level of access to your OneDrive.

## Configuring the Pi

### Create an ``rclone config``

To create an new [rclone](https://rclone.org) remote as the ``motion`` user, execute:

```bash
sudo -H -u motion rclone config
```

choosing ``Microsoft OneDrive`` as the backend and answering the prompts appropriately.

If you are running 'headless' (that is without graphical interface and can't use a browser on the Pi) you will need to follow the instructions for remote authorization, which requires you to issue an [rclone](https://rclone.org) command on a computer which does have a browser in order to authenticate with Microsoft.

* For example on a Windows machine on which you have installed [rclone](https://rclone.org) you would execute:
  * ``rclone authorize "onedrive"``

### Add a ``copymotion`` script

A ``copymotion`` script for copying to a remote web server directory when using the above autocopy configuration in ``/etc/motion/motion.conf``

Copy this script to ``/usr/local/bin/copymotion``

```bash
#!/bin/sh

( rclone copy /var/lib/motion/data onedrive-motion:/motion & )
```

**NB** This script assumes you have configured the destination for videos and photos to be ``/var/lib/motion/data`` NOT ``/var/lib/motion`` (which is the default). This is because the rclone config lives in ``/var/lib/motion/.config`` and we do not want to copy it a public OneDrive folder.
