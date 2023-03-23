---
slug: a-more-windows-centric-approach
aliases:
    - /docs/sysadmin-devops/windows-and-linux/a-more-windows-centric-approach/
    - /sysadmin-devops/windows-and-linux/a-more-windows-centric-approach/
    - /deploy-admin/a-more-windows-centric-approach/
    - /docs/deploy-admin/windows-and-linux/a-more-windows-centric-approach/
title: "A more Windows-centric approach"
author: Daniel F. Dickinson
date: '2021-07-09T11:51:00-04:00'
publishDate: '2021-07-15T06:03:00-04:00'
tags:
- linux
- sysadmin-devops
- windows
- windows-and-linux
description: "A Windows-centric approach to creating a Windows and Linux hybrid environment for developers."
summary: "A Windows-centric approach to creating a Windows and Linux hybrid environment for developers."
---

{{< details-toc >}}

## Preface

These are notes on creating a Windows and Linux hybrid environment for developers (hence the use of Windows 10 Pro not Home), specifically when running Windows on a physical machine. This version differs from most others in this section ([Windows and Linux combined](/tags/windows-and-linux/)) in that it takes a more Windows / Microsoft 365 centred approach. (Note that this focuses on personal (not commercial or non-profit organizational) use so is for the Personal or Family editions of Microsoft 365, not the Microsoft 365 for Business editions).

Also, note that this doesn't claim to be the ideal order of operations for this type of install. Even it there was only one ideal flow in my situation (which includes bringing back existing data and settings synchronized with Microsoft accounts from previous combined Windows and Linux installations), there are other situations where a different flow might be better. For instance a completely fresh install with no previously existing Microsoft account or Linux data, or a new Windows install but old Linux data, etc.

This guide is meant to give you an idea of the things to keep in mind, but should be tailored to suit your actual situation.

And finally, I don't have any devices that are eligible for Windows 11 so we're not going to go there (besides, I'd rather let the early adopters find the bugs that made it through the Insiders process).

## Process

1. [Prepare for installation (especially the media)](preparation.md)
2. [Perform the base install](base-install.md)
3. [First steps, post-install](first-steps-post-install.md)
4. [Tweaks and recommendations: Windows 10 Pro](tweaks-and-recommendations.md)
