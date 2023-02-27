---
slug: wordpress-site-health
aliases:
    - /docs/archived/intro-to-wordpress/wordpress-site-health/
    - /develop-design/web-design-web-devel/intro-to-wordpress/wordpress-site-health/
    - /docs/devel/intro-to-wordpress/wordpress-site-health/
author: Daniel F. Dickinson
date: '2021-03-03T22:06:52+00:00'
publishDate: '2021-01-29T20:53:46+00:00'
title: WordPress 'Site Health'
description: "Fixing 'Site Health' issues with default WordPress install"
series:
    - intro-to-wordpress
tags:
    - archived
    - sysadmin-devops
    - security
    - web-design
    - website
    - wordpress
weight: 20310
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Using WordPress Site Health Page

1. Hover over 'Tools' and select 'Site Health'
{{< figure alt="Site Health after initial install" caption="Site Health after initial install" src="/assets/images/2021/01/index-23_1-png-1.png" >}}
2. You should see a page like the one depicted.
3. You'll noticed there are a few recommended security improvements.

### Manage Warnings #1

1. Select 'Only parts of you site are using HTTPS'.
{{< figure alt="Settings URLs to HTTPS" caption="Settings URLs to HTTPS" src="/assets/images/2021/01/index-24_1-png-1.png" >}}
2. Select 'Update your site addresses'
3. Assuming you created an SSL certificate for your site, replace the 'http://' in 'WordPress Address (URL)' and 'Site Address (URL)' with 'https://'.
4. Select 'Save Changes'
5. You will need to login again

### Manage Warnings #2

1. Select 'Tools|Site Health' again.
2. You should now only see three recommended improvements.
3. Select 'The authorisation header is missing'.
4. Select 'Flush permalinks'.
5. Select your preferred permalink style (search engines won't like you if you change it later).
{{< figure alt="Settings permalink structure" caption="Settings permalink structure" src="/assets/images/2021/01/index-25_1-png-1-1024x433.png" >}}

### Manage Warnings #3

1. Once again, select 'Tools|Site Health'
2. You should be down to two 'recommended improvements'.
3. Select ‘You should remove inactive themes.'
4. Select ‘Manage your themes’.
5. For all themes you don’t want to use, select the theme’s thumbnail, then select ‘Delete’
6. For every theme you find interesting, select ‘Update now’, then select the theme.
7. Select ‘Enable auto-updates’.

### Manage Warnings #4

1. Once more select ‘Tools|Site Health’.
2. Select ‘You should remove inactive plugins’.
3. Select ‘Manage your plugins’.
{{< figure alt="List of installed plugins" caption="List of installed plugins" src="/assets/images/2021/01/index-27_1-png-1.png" >}}
4. For the ‘Hello Dolly’ plugin, select ‘Delete’.
5. If you want to use the ‘Akismet Anti-Spam’ plugin, select ‘update now’, otherwise select ‘Delete’ for the plugin.
6. If you keep the ‘Akismet’ plugin, you will need to configure it (not covered in this presentation).

## Site Health Verified

1. Verify that ‘Tools|Site Health’ shows a checkmark and ‘Great job! Everything is running smoothly here.’
2. If you view the actual site you should see something such as the following screenshot.

## Additional Security Measures

1. If not using Akismet Anti-Spam plugin, go to ‘Settings|Discussion’ and make sure that under ‘Before a comment appears’, ‘Comment must be manually approved’ is checked.
2. While this means you have to moderate every comment, it is essential to avoid nasty spam appearing on your site.
   * By nasty I mean not only spam that promotes ‘the nasty’, but malware, conspiracy theories, comments in languages that you (and/or most of your readers) don’t know, and normal spam that will ruin your search engine rankings (such as they are).
