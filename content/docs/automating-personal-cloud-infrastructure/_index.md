+++
slug = "automating-personal-cloud-infrastructure"
aliases = [
	"/docs/deploy-admin/automating-personal-cloud-infrastructure/",
	"/deploy-admin/automating-personal-cloud-infrastructure/"
]
author = "Daniel F. Dickinson"
date = "2022-11-16T14:10:36-0500"
publishDate = "2022-11-16T21:10:36-0500"
title = "Automating a personal 'cloud' infrastructure"
description = """\
How Daniel uses Ansible to develop, test, and deploy his
own mail servers, calendar/addressbook, websites, git archive server, and more.\
"""
summary = """\
How Daniel uses Ansible to develop, test, and deploy his
own mail servers, calendar/addressbook, websites, git archive server, and more.\
\
"""
series = [
	"automating-a-personal-cloud-infrastructure"
]
tags = [
	"debian",
	"deploy",
	"linux",
	"self-host",
	"sysadmin-devops",
	"virtualization"
]
showChildPages = false
+++

How Daniel uses Ansible to develop, test, and deploy his own mail servers,
calendar/addressbook, websites, git archive server, and more.

This is not total 'Continuous Delivery' but is 'Continuous Integration' and
'Continuous Deployment' (that is basic verification and deployment of the
infrastructure during development, testing (staging), and public deployment is
automated).

**Note** that as of 2023-02-18 (February 18, 2023), this is still under
development and not yet used for a live production deployment. It is, however
used for development (local) 'staging' deployments. 'Production' use is getting
close, and this series is lagging the actual development.

**Updated Note** this was put on hold due to various other activities and
priorities, however work will be restarted in the coming months.

## Topics

* [Bare metal cloud-init](2023-12-18-bare-metal-cloud-init.md): Using a Debian
'cloud' image and cloud-init on a 'bare-metal' host for fast deployment

### Deprecated

* [Creating base VM images](2022-11-16-base-images-for-a-personal-cloud.md):
Using Packer to create images used for a personal 'cloud' infrastructure.
_Note_: Replaced with a two-stage pure Ansible approach in the code actually
used.

-------
