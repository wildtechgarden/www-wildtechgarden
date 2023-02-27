---
slug: completing-openstacksdk-with-templating
aliases:
    - /projects/experimental-learning/infrastructure-via-code/completing-openstacksdk-with-templating/
    - /develop-design/infrastructure-via-code/completing-openstacksdk-with-templating/
    - /docs/devel/infrastructure-via-code/completing-openstacksdk-with-templating/
    - /devel/completing-openstacksdk-with-templating/
title: "ARCHIVED: IvC: Complete templating"
date: 2021-06-15T21:50:11-04:00
publishDate: 2021-06-25T02:25:11-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - devel
    - experimentation
    - infrastructure-via-code
    - jinja
    - learning
    - openstack
    - projects
    - python
    - sysadmin-devops
    - templating
description: "This page was intended to complete the OpenStack SDK with templated userdata portion of this Infrastructure via Code set"
summary: "This page was intended to complete the OpenStack SDK with templated userdata portion of this Infrastructure via Code set"
weight: 10600
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

### The Plan

This page was intended to complete the OpenStack SDK with templated userdata portion of this [Infrastructure Via Code](_index.md) set. This involves:

* Adding ``runcmd`` and ``bootcmd`` sections to ``userdata-default.yaml.jinja``
* Adding the full set of required files for the desired instances
* Combining the full userdata with ``create-instances.py`` script

We were going leave a few things to later pages; for example:

* Adding public DNS updates (required to meet some dependencies) (OVH API, not OpenStack)
* Adding other 'simple orchestration' details
* Bringing 'real' instances up with this system

None of these would have required changes to the OpenStack code.

### Halted and Why

While our internal tests (using private data that would need to be replaced with dummy data) of a full config were successful, frustrations with 'our' OpenStack hosting provider (and researching other Canadian OpenStack providers suggests that there aren't others doing a better job, and that my current provider is the one with the greatest chance of 'business continuity') has led to the conclusion that it's not a viable cloud alternative for us.

Therefore we are not continuing with this project.

In addition it is our finding that this approach involves more effort than if Terraform were a viable option, so if we were to continue with public cloud infrastructure we would prefer services with which we can successfully use Terraform.

### Code

The scripts, configs, etc described on this page are available in a Git repo @ <https://github.com/danielfdickinson/ivc-in-the-wtg-experiments>.
