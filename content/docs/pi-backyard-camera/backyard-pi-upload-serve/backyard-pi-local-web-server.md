---
slug: backyard-pi-local-web-server
aliases:
  - /post/pi-backyard-camera/backyard-pi-local-web-server/
  - /deploy-admin/pi-backyard-camera/backyard-pi-local-web-server/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-local-web-server/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-upload-serve/backyard-pi-local-web-server/
  - /backyard-pi-sub-pages/backyard-pi-local-web-server/
title: "Local web server for backyard camera"
author: Daniel F. Dickinson
date: 2021-09-22T16:19:07-04:00
publishDate: 2021-09-22T19:19:07-04:00
tags:
    - linux
    - raspberry-pi
    - self-host
description: Copying backyard camera videos and pictures to a remote web server using rclone
summary: Copying backyard camera videos and pictures to a remote web server using rclone
---

{{< details-toc >}}

## Overview

* This is similar to [allowing access to Motion](../backyard-pi-streaming.md#allow-access-to-motion-internet-to-local-pi), except that motion creates files which are served by a web server instead of motion serving them itself.
* The main advantage over allowing access to Motion itself is that webservers are more 'battle-tested' with respect to remote access flaws.
* See below for notes on [security](../backyard-pi-streaming.md#security), [port forwarding](../backyard-pi-streaming.md#port-forwarding), and/or [PageKite](../backyard-pi-streaming.md#pagekite-or-alternative).
* We don't discuss the webserver configuration here as there are many guides already available for that.
* For the ``copymotion`` script below it is assumed that the directory from which the web server is configured to serve the files is ``/var/www/html/motion`` and that is writable by the ``motion`` user. You should adapt the script as appropriate if you configure the web server with a different directory.
* We further assume that the ``rclone`` 'remote' is called ``localweb`` for this server.

## Configuring upload

A ``copymotion`` script for copying to a local web server directory when using the above autocopy configuration on ``/etc/motion/motion.conf``

Copy this script to ``/usr/local/bin/copymotion``

```bash
#!/bin/sh

( rclone copy /var/lib/motion/data localweb:/var/www/html/motion & )
```

**NB** This script assumes you have configured the destination for videos and photos to be ``/var/lib/motion/data`` NOT ``/var/lib/motion`` (which is the default). This is because the rclone config lives in ``/var/lib/motion/.config`` and we do not want to copy it to the web server.
