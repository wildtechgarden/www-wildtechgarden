---
slug: backyard-pi-remote-web-server
aliases:
  - /deploy-admin/pi-backyard-camera/backyard-pi-remote-web-server/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-remote-web-server/
  - /docs/deploy-admin/pi-backyard-camera/backyard-pi-upload-serve/backyard-pi-remote-web-server/
  - /post/pi-backyard-camera/backyard-pi-remote-web-server/
  - /backyard-pi-sub-pages/backyard-pi-remote-web-server/
title: "Remote web server for backyard camera"
author: Daniel F. Dickinson
date: 2021-09-22T16:19:07-04:00
publishDate: 2021-09-22T19:19:07-04:00
tags:
    - linux
    - raspberry-pi
    - self-host
description: Copying backyard camera videos and pictures to a local web server using rclone
summary: Copying backyard camera videos and pictures to a local web server using rclone
---

{{< details-toc >}}

## Overview

* Can be the most secure option listed here, but requires you to configure a web server on a VPS and involves more work than other methods.
* This article only discusses the rclone config. There are many existing documents on how to configure a web server to serve static files and/or enable SSH/SFTP access.
* For the ``copymotion`` script below it is assumed that the directory from which the web server is configured to serve the files is ``/var/www/html/motion`` and that is writable by the user used to SFTP the files to the server. You should adapt the script as appropriate if you configure the web server with a different directory.
* We further assume that the ``rclone`` 'remote' is called ``remoteweb`` for this server.
* You also need to configure SFTP as described below.

## Configuring SFTP for use with rclone

### On Pi

* Create a passwordless SSH key for the ``motion`` user to upload to the VPS (it is recommended the user on the VPS only have permissions required to upload motion files to the correct directory. This is known as the principle of least privilege).
  * E.g.

    ```bash
    sudo -H -u motion ssh-keygen -N '' -C motion@$(hostname -s) -t rsa
    ```

  * Make sure the ``.ssh`` directory and contents are only accessible to ``motion``:

    ```bash
    sudo chown -R motion:motion /var/lib/motion/.ssh && sudo chmod 0700 /var/lib/motion/.ssh
    ```

  * The public key to copy to the VPS ``$HOME/.ssh/authorized_keys`` in this case would be ``/var/lib/motion/.ssh/id_rsa.pub``

### On VPS

* Make sure ``/var/www/html/motion`` is has read, write, and execute permissions for the user with which you use SFTP (usually the same as your SSH user). For the purposes of this documentation we will assume the username is ``motion-uploader`` with group ``motion-uploader``.
  * For example: ``sudo mkdir -p /var/www/html/motion && sudo chown -R motion-uploader:motion-uploader /var/www/html/motion``.
* Add an SSH public key for the Pi ``motion`` user to ``$HOME/.ssh/authorized_keys`` file for the ``motion-uploader`` user on the VPS.

## Configuring the Pi

### Create an ``rclone config``

To create an new [rclone](https://rclone.org) remote as the ``motion`` user, execute:

```bash
sudo -H -u motion rclone config
```

choosing ``SFTP`` as the backend and answering the prompts appropriately.

### Add a ``copymotion`` script

A ``copymotion`` script for copying to a remote web server directory when using the above autocopy configuration in ``/etc/motion/motion.conf``

Copy this script to ``/usr/local/bin/copymotion``

```bash
#!/bin/sh

( rclone copy /var/lib/motion/data remoteweb:/var/www/html/motion & )
```

**NB** This script assumes you have configured the destination for videos and photos to be ``/var/lib/motion/data`` NOT ``/var/lib/motion`` (which is the default). This is because the rclone config lives in ``/var/lib/motion/.config`` and we do not want to copy it to the web server.
