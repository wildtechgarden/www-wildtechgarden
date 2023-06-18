---
slug: completing-bare-bones-openstacksdk
title: "IvC: Bare bones script"
date: 2021-06-07T11:30:33-04:00
publishDate: 2021-06-08T15:47:23-04:00
author: Daniel F. Dickinson
weight: 10500
aliases:
    - /projects/experimental-learning/infrastructure-via-code/completing-bare-bones-openstacksdk/
    - /develop-design/infrastructure-via-code/completing-bare-bones-openstacksdk/
    - /docs/devel/infrastructure-via-code/completing-bare-bones-openstacksdk/
    - /devel/completing-bare-bones-openstacksdk/
    - /docs/devel/infrastructure-via-code/bare-bones-openstacksdk-completion/
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - deploy
    - python
    - sysadmin-devops
description: "Continuing with the a bare bones OpenStackSDK-based deployment of instances"
summary: "Continuing with the a bare bones OpenStackSDK-based deployment of instances"
weight: 10510
showChildPages: false
---

{{< details-toc >}}

## Preface

### Some Thoughts

* At this point we should think about what is required to meet our [target requirements](../_index.md#requirements-targeted).
* We're going to put off a number of considerations as they depend on robust use of 'userdata' as we will be exploring the use of [Jinja](https://jinja.palletsprojects.com/en/3.1.x/) to template userdata later in the series.
* At this point we're still concentrating on bringing up instances (and deleting old instances if needed).
* We're also not making a 'Zero Downtime' project, where making changes is expected to result in no visible (even brief) disruption in service; that is overkill for our requirements.

### What We Need for Our Infrastructure (That We Don't Have Yet)

* Use of OpenStack Security Groups
* Handling creation of instances on both public and private networks
* Handling userdata for instances only on a private network (requires use a 'config drive')
* Attaching existing volumes
* Userdata (as mentioned, that's for later in the series)

You might notice that we are not concerned about creating volumes 'automatically'. That is because for our environment volumes are only used for permanent data. We are also not creating 'server farms' for large scale web apps. In addition, volumes come with additional fees (even if not all that large), so we want to keep volume creation manual.

### Code

The scripts described on this page are available in a Git repo @ <https://github.com/wildtechgarden/ivc-in-the-wtg-experiments>.

## Table of Contents

* [Improving the script](improving-the-script.md)
* [Adding security groups](adding-security-groups.md)
* [A sufficiently complete bare bones script](a-sufficiently-complete-bare-bones-script.md)

## Final thoughts (to date)

As you can see the experiments have gone surprisingly smoothly, and we've been able to concentrate in iteratively improving our script. Since this is an experimental process we haven't been using TDD or CI (Test Driven Development or Continuous Integration). Adding those will require some thought as it will need to be able to spin up instances during the test process, and may not be something we want to do on a public cloud offering.

For those who read this, we hope find the process we've shown proves informative, useful, and interesting. Of course we're not done yet, so we hope you will keep watching for updates.
