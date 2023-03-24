---
slug: reducing-web-server-spam-with-lighttpd
aliases:
    - /2021/04/03/reducing-web-server-spam-with-lighttpd/
    - /deploy-admin/reducing-web-server-spam-with-lighttpd/
    - /docs/sysadmin-devops/self-host/reducing-web-server-spam-with-lighttpd/
    - /sysadmin-devops/self-host/reducing-web-server-spam-with-lighttpd/
    - /docs/deploy-admin/self-host/reducing-web-server-spam-with-lighttpd/
author: Daniel F. Dickinson
date: '2021-04-04T00:05:04+00:00'
publishDate: '2021-04-04T00:05:03+00:00'
summary: I was tired excessive bot traffic spamming my logs, so I learned how
  to reduce the noise in my logs.
description: I was tired excessive bot traffic spamming my logs, so I learned how
  to reduce the noise in my logs.
tags:
- debian
- linux
- self-host
- sysadmin-devops
title: Reducing web server spam with Lighttpd
card: true
---

{{< details-toc >}}

## Preface

I've recently used [Lighttpd](https://www.lighttpd.net/) as the web server for a personal server. (I had taken a period of just using the OS default web server, which is usually Apache). Along the way I discovered a new trick. I was tired of the excessive bot traffic spamming my logs, so I did a search and found a post named [Block Bad Bots in 3 Easy Steps with Lighttpd](https://blog.ctis.me/2015/05/blocking-bad-bots-in-3-easy-steps-with-lighttpd/), which points at the [author of that article's Github repository with an example Lighttpd spam block config file](https://github.com/ctrezevant/everlasting-botstopper).

I've taken this and tweaked it a little for a Debian/Ubuntu-based Lighttpd install, and the bots that are currently actually bothering me.

### _[Update 2022-05-25]_ More on the Lighttpd issue tracker / wiki

User [gstrauss](https://redmine.lighttpd.net/users/10519) has even more bot blocking (including DDoS mitigation) [On an issue regarding too long a regexp causing a lighttpd 'assertion'](https://redmine.lighttpd.net/issues/3074),
as well as [a constant (fast) database lookup using Lua](https://redmine.lighttpd.net/attachments/2064) as part of [Using Lua scripts with Lighttpd to aid security](https://redmine.lighttpd.net/projects/lighttpd/wiki/AbsoLUAtion#Fight-DDoS).

I hope to do a more detailed writeup at some point, but for now I at least point
you to the 'work in progress' documentation.

## Managing 'Good' bots

The first step though is to make sure 'good' bots (usually search engine crawlers) don't overwhelm your site by making sure you are serving an appropriate [robots.txt](https://moz.com/learn/seo/robotstxt) for your site. If you want to centralize your robots.txt configuration you could use a file with lighttpd config sections such as (assuming you have mod\_alias enabled, which is usually in the default configuration for your distro):

```conf
$HTTP["host"] == "myvhost.example.com" {
    $HTTP["url"] =~ "^/robots.txt" {
        alias.url = (
            "/robots.txt" => "/var/local/robots/myvhost.txt"
        )
    }
}
```

(if you really wanted to get fancy you could instead use regular expressions and avoid duplicating blocks; I'm currently only using two vhosts so writing and debugging that bit of logic was more than I needed). Also remember in lighttpd, the last definition of a configuration directive wins. That means the alias.url above will only used if the above condition is the last time an alias.url is set. See the [Lighttpd configuration syntax page for more information on the rules around merging of directives](https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_Configuration#Conditional-Configuration-Merging).

If you are running a Debian/Ubuntu-based server you would:

1. Put the above in the folder /etc/lighttpd/conf-available as a file such as 40-robots-txt.conf
2. When you are ready to go live with the robots file's, issue the command lighttpd-enable-mod robots-txt
3. And then systemctl restart lighttpd

## Denying 'Bad' bots

Here we deny access using mod_access to return HTTP code 403 Forbidden for matches on condition we deem suspicious. We also send the logs of the traffic matching these conditions to /var/log/lighttpd/spam.log so that our regular access.log omits this irrelevant (from a statistics point of view) traffic. If we really want we can do separate statistics on the spam.log to see if we could block the traffic from even reaching the web server.

### Create a bot denying configuration

A sample 70-deny-bad-bots.conf for /etc/lighttpd/conf-available could be:

```conf
# Block some (usually) malicious traffic

# Empty UA, or -
$HTTP["useragent"] == "" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}
$HTTP["useragent"] == "-" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# Block bad requests with empty "Host" headers.
$HTTP["host"] == "" {url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}
$HTTP["host"] == "-" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# Block requests by IP; not likely to be legitimate traffic
$HTTP["host"] =~ "(ips-of-your-server)(:(80|443))?" {url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# cURL and Wget/HTTP Libraries commonly used by skiddies
$HTTP["useragent"] =~ "curl|Wget" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log" }
$HTTP["useragent"] =~ "libwww-perl|Apache-HttpClient|Nmap\ Scripting\ Engine|Mozilla\ FireFox\ Test|python-requests" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# Deny all URLs to likely malicious UAs (minimizing access to potentially vulnerable apps).
$HTTP["useragent"] =~ "perl|\{|\}|\/var\/|\/tmp\/|\/etc\/|China.Z|ZmEu|Zollard|gawa\.sa\.pilipinas|Jorgee" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# Block bots I actually see and are a problem
$HTTP["useragent"] =~ "redacted1|redacted2" { url.access-deny = ( "" ) accesslog.filename = "/var/log/lighttpd/spam.log"}

# Block URLs that are certainly attempts at malicious behaviour
$HTTP["url"] =~ "^/(redacted1|redacted2|...|redacedn)" { url.access-deny = ("") accesslog.filename = "/var/log/lighttpd/spam.log" }

# Queries that are likely malicious
$HTTP["querystring"] =~ "(XDEBUG_SESSION_START|HelloThinkCMF)" { url.access-deny = ("") accesslog.filename = "/var/log/lighttpd/spam.log" }

# Always allow access to robots.txt, to everyone.
$HTTP["url"] =~ "^/robots.txt"{ url.access-deny = ("disable") }
```

You'll notice I've redacted some of the blocking criteria. This is because I'd rather not make it any easier for a targeted attacker than I already do simply by trying to provide helpful information to my readers. I'm not convinced it makes a lot of difference, but I'd rather publish too much than too little, because I'm about helping people, not hiding cowering in a hole, and saying nothing to anyone, or publishing anything.

### Enable the configuration

1. When you are ready to go live with the robots file’s, issue the command lighttpd-enable-mod deny-bad-bots
2. And then systemctl restart lighttpd

## Conclusion

This tips aren't going to bulletproof your server, but they will move a lot of log spam into your spam log, keep a significant amount of malicious traffic from accessing your actual pages for web apps, and hopefully make the rest of your logs more statistically useful. All going well you also discourage the bots from visiting quite so much.
