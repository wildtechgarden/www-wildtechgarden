---
slug: real-life-systemd-timers
aliases:
- /deploy-admin/real-life-systemd-timers/
- /docs/deploy-admin/sysadmin-devops/real-life-systemd-timers/
- /deploy-admin/sysadmin-devops/real-life-systemd-timers/
title: "Real life SystemD timers"
date: 2022-03-07T21:56:48Z
publishDate: 2022-03-07T21:56:48Z
author: Daniel F. Dickinson
tags:
    - git
    - linux
    - sysadmin-devops
description: "Fully configured details of two SystemD timer use cases"
summary: "Most blog entries on SystemD timers give trivial samples. This article takes a different approach and provides the full details of two examples of using SystemD timers that are in active use on my systems."
card: true
---

{{< details-toc >}}

## Preface

Most blog entries on SystemD timers give trivial samples. This article takes a different approach and provides the full details of two examples of using SystemD timers that are in active use on my systems.

## Prerequisites

* Knowledge of basic Linux system administration for a SystemD-based distribution.
* For the first example (one could of course substitute a different software package and adjust the example to suit):
  * We use ``restic``, so to follow along exactly one should understand the [restic docs](https://restic.readthedocs.io/en/stable/).
  * The [latest version of restic](https://github.com/restic/restic/releases/latest) installed to ``/usr/local/sbin/restic``.
  * A user named `restic` with primary group `restic` and home directory ``/home/restic``
  * A password for a restic repository defined in ``/home/restic/password-file``
  * Restic repository access information defined in ``/home/restic/repository-file``
* For the second example we execute a command that pipes to stdout (which we redirect to a FIFO), which becomes (through the FIFO) stdin for the ``restic`` command that backs the data sent in on stdin to the encrypted restic backup repository.
* In addition to basically the same prerequisites (but a different password-file and repository-file) as the first example, the second example requires:
  * [Gitea](https://docs.gitea.io) installed and running as user ``gitea`` with primary group ``gitea``
  * gitea user has home directory ``/srv/gitea/home``
  * gitea 'work dir' is ``/srv/gitea/data``

## Example #1

A daily backup of the select parts of a Linux system using ``restic``.

Note that ``AmbientCapabilities=CAP_DAC_READ_SEARCH`` enables the task to access read all files on the system even though the user is 'only' `restic` and not `root`.

### The task to execute each day

This goes in ``/etc/systemd/system/restic-daily.service``

```ini
[Unit]
Description=Execute restic once a day

[Service]
# Only execute a single time per timer trigger (from the .timer file)
Type=oneshot
# Act at quite a low priority so that when this triggers it doesn't
# interfere with the primary functions of the device/VM
Nice=17
# Executes the actual backup run (restic binary)
# Adjust the --exclude options and directories to include as suits
# your system
ExecStart=/usr/local/sbin/restic --repository-file /home/restic/repository-file --password-file /home/restic/password-file --cleanup-cache --quiet backup --one-file-system --exclude-caches --exclude /root/.cache --exclude /var/lib/libvirt --exclude /var/lib/docker --exclude /var/lib/postgresql /etc /root /var/backups /var/lib /var/local /var/lock /var/log /var/mail /var/opt /var/spool /srv/gitea/home /home
User=restic
Group=restic
AmbientCapabilities=CAP_DAC_READ_SEARCH
# Everything that follows this comment is about sandboxing restic as much
# as possible for a program that is doing a system-level backup. For
# details see the systemd.exec(1) man page
SystemCallFilter=@basic-io @aio @debug @file-system @io-event @ipc @network-io @obsolete @privileged @process @resources @signal @sync @timer
SystemCallErrorNumber=EPERM
ProtectSystem=full
ReadWritePaths=/home/restic/.cache
PrivateTmp=true
NoNewPrivileges=yes
ProtectHostname=yes
ProtectClock=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
MemoryDenyWriteExecute=yes
SystemCallArchitectures=native
RestrictSUIDSGID=yes
PrivateMounts=yes
```

### The SystemD timer (this triggers the task once a day)

It goes in ``/etc/systemd/system/restic-daily.timer``

```ini
[Timer]
OnActiveSec=24h # Time to wait before triggering restic-daily.service,
                # once after boot
OnUnitActiveSec=24h # Time to wait between executions of
                    # restic-daily.service
RandomizedDelaySec=300 # 0-300 second delay added to each execution delay
Persistent=yes

[Install]
WantedBy=timers.target
```

### Enabling the SystemD Restic timer task

Executing ``systemctl daemon-reload && systemctl enable --now restic-daily.timer`` will start the timer, which will cause an execution in 24h + a delay of 0-300 seconds, followed by execution every 24h thereafter (with a 0-300 second delay).

## Example #2

### The .service files for a Gitea dump to restic

#### Task to create FIFO if it does not already exist

Goes in ``/etc/systemd/system/gitea-backup-fifo.service``

```ini
[Unit]
Description=Create Gitea Dump FIFO
# Only execute the command below if the FIFO does not exist
ConditionPathExists=!/run/gitea/gitea_db_dump

[Service]
# Only execute the command once per trigger (either of the other
# .service files for this example)
Type=oneshot
# Make sure the directory containing the FIFO exists and is
# only accessible by the owner
ExecStartPre=mkdir -m 0700 -p /run/gitea
# Make sure the FIFO exists
ExecStart=mkfifo -m 0600 /run/gitea/gitea_db_dump
```

#### The Gitea task to periodically execute (stdout)

Goes in ``/etc/systemd/system/restic-gitea-dump.service``

```ini
[Unit]
Description=Dump Gitea data once an hour
# Execute after the FIFO has been created
After=gitea-backup-fifo.service
# Execute gitea-backup-fifo.service (make the FIFO) if this has not
# already been done
Requires=gitea-backup-fifo.service

[Service]
Environment="USER=gitea" "HOME=/srv/gitea/home" "GITEA_WORK_DIR=/srv/gitea/data"
# Only execute a single time per timer trigger
# (from the restic-gitea-backup.service file)
Type=oneshot
# Act at quite a low priority so that when this triggers it doesn't
# interfere with the primary functions of the device/VM
Nice=17
User=gitea
Group=gitea
# Send logs to the systemd journal
StandardError=journal
# Send stdout (the tarball generated below and sent to stdout via '-f -') to FIFO
StandardOutput=file:/run/gitea/gitea_db_dump
# The actual gitea dump to a tarball on stdout
ExecStart=/usr/local/sbin/gitea --config /etc/gitea/app.ini dump --custom-path /srv/gitea/data/custom --work-path /srv/gitea/data --type tar.gz -f -
# Everything that follows this comment is about sandboxing gitea as much
# as possible. For details see the systemd.exec(1) man page
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
NoNewPrivileges=yes
ProtectHostname=yes
ProtectClock=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
MemoryDenyWriteExecute=yes
SystemCallArchitectures=native
RestrictSUIDSGID=yes
```

#### The restic task to periodically execute (stdin)

Goes in ``/etc/systemd/system/restic-gitea-backup.service``

```ini
Description=Receive Gitea Data Dump
# Execute after the FIFO has been created
After=gitea-backup-fifo.service
# Execute gitea-backup-fifo.service (make the FIFO) if this has not
# already been done.
# Also start restic-gitea-dump.service since we need it to consume
# the data we generate (to store in backup)
Requires=gitea-backup-fifo.service restic-gitea-dump.service

[Service]
# Only execute a single time per timer trigger (from the .timer file)
Type=oneshot
# Act at quite a low priority so that when this triggers it doesn't
# interfere with the primary functions of the device/VM
Nice=17
User=restic
Group=restic
# See comments from Example #1, but we using --stdin and with filename
# /gitea-dump.tar.gz rather than specifying filesystem paths to
# include or exclude.
ExecStart=/usr/local/sbin/restic --repository-file /home/restic/gitea-restic-files/repository-file --password-file /home/restic/gitea-restic-files/password-file --cleanup-cache --quiet backup --stdin-filename /gitea-dump.tar.gz --stdin
# Send stdout and stderr (logs) to SystemD journal
StandardOutput=journal
StandardError=journal
StandardInput=file:/run/gitea/gitea_db_dump
# Everything that follows this comment is about sandboxing restic as much
# as possible when using a FIFO. For details see
# the systemd.exec(1) man page
SystemCallFilter=@basic-io @aio @debug @file-system @io-event @ipc @network-io @obsolete @privileged @process @resources @signal @sync @timer
SystemCallErrorNumber=EPERM
NoNewPrivileges=yes
ProtectHostname=yes
ProtectClock=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
MemoryDenyWriteExecute=yes
SystemCallArchitectures=native
RestrictSUIDSGID=yes
```

### The .timer file for a Gitea dump to restic

Goes in ``/etc/systemd/system/restic-gitea-backup.timer``

```ini
[Timer]
OnActiveSec=1h # Set to time after boot after which to launch first backup
OnUnitActiveSec=1h # Set this to how often to repeat
                   # backup task (1/hour in this example)
RandomizedDelaySec=120 # 0-120 seconds delay (random)

[Install]
WantedBy=timers.target
```

### Enabling the SystemD Gitea backup timer task

Executing ``systemctl daemon-reload && systemctl enable --now restic-gitea-backup.timer`` will start the timer.

The timer will trigger ``restic-gitea-backup.service`` which will ensure ``gitea-backup-fifo.service`` is triggered along with ``restic-gitea-dump.service`` (which will make sure it occurs after ``gitea-backup-fifo.service``).

This results in the FIFO being created and ``restic-gitea-dump`` dumping Gitea's data into the FIFO as ``restic-gitea-backup`` pulls it out of the FIFO and stores it in the encrypted backup repository.
