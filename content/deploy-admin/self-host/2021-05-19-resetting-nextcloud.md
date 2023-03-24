---
slug: resetting-nextcloud
aliases:
    - /docs/sysadmin-devops/self-host/resetting-nextcloud/
    - /sysadmin-devops/self-host/resetting-nextcloud/
    - /deploy-admin/resetting-nextcloud/
    - /docs/deploy-admin/self-host/resetting-nextcloud/
title: "Resetting Nextcloud"
date: 2021-05-19T22:04:42-04:00
publishDate: 2021-05-20T07:32:04-04:00
tags:
- linux
- self-host
- sysadmin-devops
summary: "You may realize that you really wish you could start the Nextcloud instance from scratch without the hassle of a reinstalling."
description: "You may realize that you really wish you could start the Nextcloud instance from scratch without the hassle of a reinstalling."
card: true
---

{{< details-toc >}}

## Preface

Once you have experimented with Nextcloud and gotten the system tweaked as you wish, you may realize that you really wish you could start the Nextcloud instance from scratch, but without the hassle of a reinstalling.  That's what this article is about.

**WARNING**: All existing data is erased during this procedure!

### Caveat

Configuration done inside Nextcloud (like app installations) is destroyed by this procedure.

## Backup everything

Since this is a destructive procure, make sure you can recover if you change your mind, or make a mistake and lose configuration you actually want.

Details depend on how you have decided to do backups, so are not detailed here.

## Disconnect all your clients

* On any connected clients for which you are using the 'Nextcloud' app, remove the server.
* For any 'calendar' or 'contacts' (and so on) clients, remove the server you are resetting.

## Shutdown the server

On the Nextcloud server:

``sudo systemctl stop nginx``

``sudo systemctl stop php7.4-fpm`` (or 7.3 on debian/raspbian buster)

## Remove your Nextcloud data

### Remove data in the filesystem

```bash
sudo su -
rm -rf /srv/nextcloud-data/* /srv/nextcloud-data/.htaccess /srv/nextcloud-data/ .ocdata
exit
```

(assuming you have chosen ``/srv/nextcloud-data`` as your data directory)

Alternatively you could unmount /srv/nextcloud-data and recreate the filesystem.

### Drop the Nextcloud database and recreate

```bash
sudo su - postgres
dropdb nextclouddb
```

For C.UTF-8 below substitute the appropriate UTF-8 locale:

```bash
createdb -O nextclouddb --encoding UTF8 --locale C.UTF-8 --template template1 nextclouddb
exit
```

## Remove your previous Nextcloud instance config

``sudoedit /var/www/nextcloud/config/config.php``

Remove ``instanceid``, ``passwordsalt``, ``secret``, ``dbtableprefix`` and ``installed`` config keys.

``sudo touch /var/www/nextcloud/CAN_INSTALL``

## Start Your servers

```bash
systemctl start php7.4-fpm (or 7.3 for debian buster)
systemctl start nginx
```

## Use the installation wizard (first login)

Or the command line tool (occ).  For more details see [installation wizard](https://docs.nextcloud.com/server/latest/admin_manual/installation/installation_wizard.html) or [installing from the command line](https://docs.nextcloud.com/server/latest/admin_manual/installation/command_line_installation.html).

### Login

Once you have a successful configuration I recommend a test login. In addition, it would be a good idea to enable "Server-side Encryption" in "Settings" (but only if you do not have full disk encryption enabled, otherwise the system will get too slow).
