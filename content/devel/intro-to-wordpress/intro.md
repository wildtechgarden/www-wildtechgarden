---
slug: intro
author: Daniel F. Dickinson
date: '2021-03-07T17:39:53+00:00'
publishDate: '2021-01-29T15:15:51+00:00'
title: "Introduction"
description: "Introduction to installing and using WordPress on a VPS"
summary: "Introduction to installing and using WordPress on a VPS"
series:
    - intro-to-wordpress
tags:
    - archived
    - design
    - web-design
    - website
    - wordpress
weight: 20100
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

I recommend learning enough technical skills to be able to effectively use [Hugo](https://gohugo.io) and themes created for it, rather than using WordPress. My biggest caveats with WordPress are:

* Security; Using a dynamic web publishing platform like WordPress is like painting a target on your back.
  * The dynamic nature and the fact you can log in from anywhere on the internet to edit your site, manage comments, etc., while convenient is targeted by automatic probes that will hit your site many hundreds, or thousands of times a day.
  * WordPress is often managed by **YOU**, the user. Even if you're paying for hosting, chances are the hosting company does not manage your WordPress instance (if you're not sure there is a high probability you have a vulnerable WordPress instance, due to lack of updates and monitoring).
  * The content is stored in a database, which is another point of entry for an attacker.
* Online editing is a pain;
  * Online editors tend not to be as good as editors available for offline document creation, editing and formatting.
  * In particular if the site data gets mangled, or you're changing themes, you may need to edit and reformat. With an online editor there are few timesavers available for dealing with that
* Lack of control
  * While there is an export function, it doesn't export the 'Media Library', and is the result is not an easy to edit format.
  * While live, the data is stored in a database, which makes it relatively hard to manage compared to a statically generated site.

In short, while there is a learning curve to Hugo, it's well worth the effort, and WordPress's appearance of being easy to use, is a bit of a mirage, unless you are paying more for to someone manage it for you.

## Original Document Follows

## WordPress Uses

* Blogs
  * Originally designed for this
* From the authors (<https://wordpress.org/about/features/>):
  * personal blog or website, a photoblog, a business website, a professional portfolio, a government website, a magazine or news website, an online community, even a network of websites. You can make your website beautiful with themes, and extend it with plugins. You can even build your very own application.
* Marketing / Sales (with plugins like Shopify)

### Demo of Adding a Blog Post

* This will be a live demo (so not in the slide deck).
* Login as an author
* Presenter has some prepared text; Could also use builtin editor
  * Don’t forget to make sure browser spell check is enabled if you do that
* Add tags and categories
* Pick a ‘featured image’; (optional, but readers like)
* Publish (past, future, now, or after approved by an editor) and view the resulting post (and updated lists of posts).

### Easy to use Content Management System

* Has some control to allow ‘Roles’ such as ‘Writer’ vs ‘Editor’ vs ‘Admin’
* Allows publication to occur automatically at a future date and time
* Can require (or choose to have) articles / posts / pages to be reviewed before they are published
* Allows to create and edit posts and pages ‘on-the-fly’
* Can also import posts and pages (fairly limited in this respect)
* No knowledge of underlying technologies like HTML / CSS / JavaScript etc. required, unless you want to design a theme
* Readers can comment (if you allow this).

## An Ecosystem

* Many free and paid ‘themes’ available
  * Themes are a major part of the WordPress experience as they determine not only the ‘look’ of the site, but what parts you can modify, and what features (like sidebars) you have or don’t have available.
* Plugins available to provide additional features (including e.g. Shopify)
* Many third party hosts as well as ‘wordpress.com’
* I use OVH Canada because I use it for other purposes as well, it’s inexpensive, and the hosting is in Canada (which matters to me).
* You can even host on your own hardware without paying a fee.

## Open Source

* WordPress’ creation, success, and low cost are a direct result of it being an ‘Open Source’ project.
* [wordpress.org](https://wordpress.org/) is the official home of the open source project, while it’s [wordpress.com](https://wordpress.com/) sister site provides for-fee services such as hosting, technical support for the WordPress software, as well as user support and training.
* It’s ‘Open Source’ status comes the fact that the core WordPress software is available to anyone who uses WordPress and can be modified (or not) and distributed under the terms of the [GPLv2 license](https://wordpress.org/about/license/) without paying licensing fees for doing so.

## Installing, Configuring and Using WordPress

* [OVH WordPress Setup Notes](ovh-setup/)
* [General Setup and Configuration Notes](setup/)
* [WordPress 'Site Health'](wordpress-site-health/)
* [Creating a Basic Blog](basic-blog/start-basic-blog/)
* [Featured Image Plugin](featured-image-plugin/)
* [A Note on Maintenance](a-note-on-maintenance/)
