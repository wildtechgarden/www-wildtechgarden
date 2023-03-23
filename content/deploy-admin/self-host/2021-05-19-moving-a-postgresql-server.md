---
slug: moving-a-postgresql-server
aliases:
    - /docs/sysadmin-devops/self-host/moving-a-postgresql-server/
    - /sysadmin-devops/self-host/moving-a-postgresql-server/
    - /deploy-admin/moving-a-postgresql-server/
    - /docs/deploy-admin/self-host/moving-a-postgresql-server/
title: "Moving a PostgreSQL server"
date: 2021-05-19T22:04:42-04:00
publishDate: 2021-05-20T07:32:04-04:00
tags:
- database
- linux
- self-host
- sysadmin-devops
summary: "At some point you may need to upsize your PostgreSQL server, particular if you have implemented one on a old Raspberry Pi."
description: "At some point you may need to upsize your PostgreSQL server, particular if you have implemented one on a old Raspberry Pi."
---

{{< details-toc >}}

## Preface

At some point you may need to upsize your PostgreSQL server, particular if you have implemented one on a old Raspberry Pi. This article discusses moving your server to a new home.

## Create the new server

Before you can move the old data to a new server, you need a new server.  The [PiSQL](2021-05-11-pisql.md) article is mostly applicable (although you will do your initial base OS configuration different than from a Raspberry Pi setup) if you are using Debian or Ubuntu to host the new server, so use that, or the guide of your choice, to stand up a new PostgreSQL server.

## Transfer the old server's data to the new

### Stop all services that use the old server

This could involve multiple hosts, but we don't want new data to be written to server as it will be lost.

### Dump the old data

On the old server:

1. ``sudo su -``
2. Change to a directory with a large amount of space.
3. ``sudo -u postgres pg_dumpall -c --if-exists >oldpgdata.sql``

### Copy the old data to the new server

Copy the file ``oldpgdata.sql`` to the new server.

### 'Restore' the data into the new server

```bash
sudo -u postgres psql -f oldpgdata.sql postgres 2>&1 | tee restore.log
```

Check the restore.log for any relevant errors (non-existing databases to drop, 'postgres', and 'template1' already existing are expected).  If there are none, you should be able use the databases.

## Use the new server

Point your existing services at the new server instead of the old.

## Configure backups

As usual, configure backups of the databases (see PiSQL guide, for example).

## Decommission the old server

You should now be able to shut down the older server for good.
