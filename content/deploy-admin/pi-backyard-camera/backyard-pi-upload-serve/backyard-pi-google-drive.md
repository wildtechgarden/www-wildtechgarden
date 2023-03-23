---
slug: backyard-pi-google-drive
aliases:
  - /post/pi-backyard-camera/backyard-pi-google-drive/
  - /deploy-admin/pi-backyard-camera/backyard-pi-google-drive/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-google-drive/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-upload-serve/backyard-pi-google-drive/
  - /backyard-pi-sub-pages/backyard-pi-google-drive/
title: "Backyard Pi Google Drive"
author:
date: 2021-09-23T02:46:23Z
publishDate: 2021-09-23T02:46:23Z
tags:
    - hosting
    - linux
    - presentations
    - raspberry-pi
    - technology
description: Copying backyard camera videos and pictures to Google Drive using rclone
summary: Copying backyard camera videos and pictures to a Google Drive using rclone
---

{{< details-toc >}}

## Overview

* This article only discusses the rclone config.
* For the ``copymotion`` script below it is assumed that the directory from which the Google Drive is configured to serve the files is ``/motion``.  You should adapt the script as appropriate if you configure the Google Drive to share a different directory for motion files.
* We further assume that the ``rclone`` 'remote' is called ``google-drive-motion`` for this server.

### Security

* For the ``ID of the root folder`` prompt for ``rclone config`` you may wish to first create a folder (e.g. ``motion-root``) in Google Drive and use the Folder ID as the ID of the root folder. This will limit rclone's access to that folder. You would then make ``/motion-root/motion`` shared with whomever you wish to share the motion files (public is an option for this), but the script would still use ``google-drive-motion:/motion`` as the path. See the [Google Drive backend documentation for Rclone](https://rclone.org/drive/#root-folder-id) for more details.

## Configuring the Pi

### Create an ``rclone config``

To create an new [rclone](https://rclone.org) remote as the ``motion`` user, execute:

```bash
sudo -H -u motion rclone config
```

choosing ``Google Drive`` as the backend and answering the prompts appropriately. (Do not configure as a 'Shared Drive (Team Drive)').

If you are running 'headless' (that is without graphical interface and can't use a browser on the Pi) you will need to follow the instructions for remote authorization, which requires you follow the link provided by rclone on a computer with a browser and to copy the resulting authorization code back into the config prompt on the Pi.

### Add a ``copymotion`` script

A ``copymotion`` script for copying to a remote web server directory when using the above autocopy configuration in ``/etc/motion/motion.conf``

Copy this script to ``/usr/local/bin/copymotion``

```bash
#!/bin/sh

( rclone copy /var/lib/motion/data google-drive-motion:/motion & )
```

**NB** This script assumes you have configured the destination for videos and photos to be ``/var/lib/motion/data`` NOT ``/var/lib/motion`` (which is the default). This is because the rclone config lives in ``/var/lib/motion/.config`` and we do not want to copy it to a public Google Drive folder.
