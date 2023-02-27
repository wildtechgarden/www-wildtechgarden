---
slug: openstacksdk-with-templating
aliases:
    - /projects/experimental-learning/infrastructure-via-code/continuing-openstacksdk-with-templating/
    - /develop-design/infrastructure-via-code/continuing-openstacksdk-with-templating/
    - /docs/devel/infrastructure-via-code/continuing-openstacksdk-with-templating/
    - /devel/continuing-openstacksdk-with-templating/
title: "ARCHIVED: IvC: Continuing templating"
date: 2021-06-13T19:29:29-04:00
publishDate: 2021-06-15T19:17:10-04:00
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
description: "Adding basic templates to an OpenStackSDK-based SDK deployment"
summary: "Adding basic templates to an OpenStackSDK-based SDK deployment"
weight: 10610
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

Adding templating with the ability to add files to the instance and to run scripts during the instance deployment will get us most of the way to a complete solution for our needs, so that's what this page is about.

### Code

The scripts described in this section are available in a Git repo @ <https://github.com/danielfdickinson/ivc-in-the-wtg-experiments>.

## Section Contents

* [Just a template](just-a-template.md)
* [Adding basic write files support](adding-basic-write-files-support.md)
* [Combining templates and write files support](adding-templates-to-write-files-support.md)

## Next Steps

* Add ``runcmd`` and ``bootcmd`` sections to ``userdata-default.yaml.jinja``
* Add the full set of required files for the desired instances
* Combine with ``create-instances.py`` script
* Add public DNS updating (required to meet some dependencies) (OVH API, not OpenStack)
* Test launch the desired instances
* Improve the code & config, test, improve, etc until satisfied  (for now).
* Add a wrap up note for this series.
