---
slug: setup
aliases:
   - /docs/archived/intro-to-wordpress/setup/
   - /docs/archived/intro-to-wordpress/basic-blog/setup/
   - /develop-design/web-design-web-devel/intro-to-wordpress/setup/
   - /docs/devel/intro-to-wordpress/setup/
author: Daniel F. Dickinson
date: '2021-03-08T10:23:50+00:00'
publishDate: '2021-01-29T21:14:43+00:00'
title: Initial WordPress Setup
description: "Setting up a WordPress blog on a VPS-hosted instance"
summary: "Setting up a WordPress blog on a VPS-hosted instance"
series:
    - intro-to-wordpress
tags:
    - archived
    - sysadmin-devops
    - web-design
weight: 20300
---

{{< details-toc >}}

## Initial Purchase / Install

1. Choose a hosting service
2. If the hosting service is not also a domain registrar, sign up for a domain with a domain hosting service.
3. For a ‘all-in-one’ hosting service (Domain registration, plus DNS, plus hosting of WordPress), you choose one or more domains as part of the sign-up (onboarding) process.
   * For example I have wildtechgarden.com and wildtechgarden.ca pointing to a WordPress instance. In addition, danielfdickinson.ca and danieldickinson.ca point to the same WordPress instance (though different from the one for the wildtechgarden.* domains).
4. In the address bar use **https** NOT *http.* (http is unencrypted and is less secure).

{{< figure alt="Browser address bar showing using WordPress SSL" caption="Browser address bar showing using WordPress SSL" src="/assets/images/2021/01/index-18_1-png-1.png" >}}

## Login

1. The full URL (web address) of you WordPress Login page is: ``https://domain.tld/wp-login`` (where domain.tld is the domain you purchased such as example.com).
   * I recommend you do not click on the email link as it uses http.

{{< figure alt="WordPress login screen" caption="WordPress login screen" src="/assets/images/2021/01/index-18_2-png-1.png" >}}

## Edit the Admin User

1. On the top right, select admin
{{< figure alt="Admin user drop down menu" caption="Admin user drop down menu" src="/assets/images/2021/01/index-19_1-png-1.png" >}}
2. In the drop down select admin
{{< figure alt="Admin User settings screen" caption="Admin User settings screen" src="/assets/images/2021/01/index-19_2-png-1-1024x674.png" >}}
3. Scroll down to the ‘New Password’ Section.
4. Select ‘Generate Password’
{{< figure alt="Generated password" caption="Generated password" src="/assets/images/2021/01/index-19_3-png-1.png" >}}
5. Record your new password.
6. Select ‘Update’.
7. ‘Log Out Everywhere Else’

## Set some basic site settings

1. On the left sidebar, select ‘Settings’ and scroll to ‘Site Language’
{{< figure alt="General settings page" caption="General settings page" src="/assets/images/2021/01/index-20_1-png-1-926x1024.png" >}}
2. Choose ‘English (Canada)’ (for Canadian viewers only).
3. Select ‘Save Changes’

## Make sure WordPress is up to date

1. Select ‘Please update now.’
{{< figure alt="General Settings with please update now message" caption="General Settings with please update now message" src="/assets/images/2021/01/index-21_1-png-1.png" >}}
2. Select ‘Update Now’
{{< figure alt="Update page" caption="Update page" src="/assets/images/2021/01/index-21_2-png-1.png" >}}
3. Once the update is complete you will see ‘WordPress 5.6’ (as of 2021-01-28 8:11 AM EST) and a title ‘Welcome to WordPress 5.6’.

A few things remain for a secure WordPress site in 2021.

## Select Site Theme

1. On the left, select ‘Appearance’
{{< figure alt="Theme page" caption="Theme page" src="/assets/images/2021/01/index-22_1-png-1.png" >}}
2. Select ‘Update now’ on the ‘Twenty Twenty-One theme.
3. Then select ‘Activate’.

You’re now running WordPress with the Twenty Twenty One theme.

Next up: using the ‘Site Health’ tool.
