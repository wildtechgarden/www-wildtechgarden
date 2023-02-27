---
slug: iac
aliases:
    - /projects/experimental-learning/infrastructure-via-code/
    - /develop-design/infrastructure-via-code/
    - /docs/devel/infrastructure-via-code/
title: "ARCHIVED: Infrastructure via code"
date: 2021-06-06T13:05:18-04:00
publishDate: 2021-06-06T17:14:46-04:00
author: Daniel F. Dickinson
description: Learning experiments in using bespoke code & data under version control to consistently deploy virtual and bare metal hosts and the applications on them.
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - devel
    - experimentation
    - infrastructure-via-code
    - learning
    - openstack
    - sysadmin-devops
    - projects
    - python
weight: 10100
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## ARCHIVED

This collection of pages is archived and may contain out-of-date or no longer accurate information.

## Overview

Learning experiments in using bespoke code & data under version control to consistently deploy virtual and bare metal hosts and the applications on them.

### Objective

* To determine if a bespoke code & data approach will meet the identified requirements.

### Code

The various scripts and dummy configuration files are available in a Git repository @ <https://github.com/danielfdickinson/ivc-in-the-wtg-experiments>

### Why

These meanderings were initiated due to the issues described in [Terraforming OVH Is Not Paradise](https://www.danielfdickinson/blog/terraforming-with-ovh-is-not-paradise/) in which [Terraform](https://www.terraform.io) developed issues after a relatively short time (\< two months) of using it to manage a personal infrastructure on OVH. This seems to be due to Terraform making the assumption that the unique id's for resources it manages are permanent and this assumption not holding true for the OVH API nor for OpenStack at OVH.

In addition, this has been a chance for the author to practise Python 3 programming since that isn't his strongest language.

## Requirements Targeted

1. Manage a small infrastructure in a formalized, mostly automated, manner.
2. Avoid changes to infrastructure that get missed when rebuilding an instance.
3. Prefer to rebuild from a known image state rather than an 'ad-hoc patch/change' on top of 'ad-hoc patch/change' approach.
   1. This helps keeps the systems 'cleaner', more organized, and encourages better thought out changes.
4. Ensure that data and configuration that should survive across a rebuild actually does.
   1. Permanent data needs to on volumes that are 'permanent' (unless upgraded or replaced; in which cases the data needs to be migrated).
   2. Deployment needs to handle both the 'blank slate' case and the 'existing data' case.
5. Avoid unintended changes to the data or behaviour of the systems on rebuild, especially user-facing ones.
6. Automate routine system administration (backups, package updates, SSL certificate updates, etc) as much as practical, while minimizing disruption to services offered by the infrastructure.
7. Be security conscious (avoid passwordless sudo, avoid passwordless SSH with administrative access, and other overly common cloud security weaknesses)
   1. As much as possible a deployed instance should be immutable.
   2. In particular, it's a major flaw to allow a remote system to automatically make arbitrary changes to a system.
   3. Avoid putting 'secrets' in OpenStack userdata or equivalent for other systems.
8. Avoid being too onerous or time consuming for needed changes to be made
9. Minimize the time and effort required for maintainance once 'known good' configurations are 'live'.
10. Repeat for local Libvirt instances and 'bare metal' hosts.

## A Note on the Base Environment

These instances are based on top of an image that has already prepared a few things about the environment:

1. Hashicorp Vault is installed (for most instances for use as a client).
2. The default ubuntu user has been removed (in part to eliminate a passwordless sudo user) and replaced by the admin user you see defined in our userdata.
3. snapd has been removed (for our instances we don't use snaps).
4. Several packages we find useful have been installed.
5. A number of tweaks we find useful have been applied.

## Conclusion

While our internal tests (using private data that would need to be replaced with dummy data) of a full config were successful, frustrations with 'our' OpenStack hosting provider (and researching other Canadian OpenStack providers suggests that there aren't others doing a better job, and that my current provider is the one with the greatest chance of 'business continuity') has led to the conclusion that it's not a viable cloud alternative for.

Therefore we are not continuing with this project.

In addition it is our finding that this approach involves more effort than if Terraform were a viable option, so if we were to continue with public cloud infrastructure we would prefer services with which we can successfully use Terraform.

## Sections

* [Tokens for OVH v1](2021-06-06-tokens-for-ovh-v1)
* [First steps with OpenStackSDK](2021-06-06-first-steps-with-openstacksdk)
* [Adding trivial templating](2021-06-09-adding-trivial-templating)
* [Continuing OpenStackSDK with templating](continuing-openstacksdk-with-templating/openstacksdk-with-templating)
* [Completing bare bones SDK](completing-bare-bones-openstacksdk)
* [Completing OpenStackSDK with templating](2021-06-15-completing-openstacksdk-with-templating)
