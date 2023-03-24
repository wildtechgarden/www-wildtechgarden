---
slug: yet-another-web-server-howto
aliases:
    - /2019/10/05/yet-another-web-server-howto/
    - /post/yet-another-web-server-howto/
    - /deploy-admin/yet-another-web-server-howto/
    - /yet-another-web-server-howto/
    - /docs/sysadmin-devops/self-host/yet-another-web-server-howto/
    - /sysadmin-devops/self-host/yet-another-web-server-howto/
    - /docs/deploy-admin/self-host/yet-another-web-server-howto/
title: "Yet another web server HOWTO"
author: Daniel F. Dickinson
date: 2019-10-05T18:20:00+00:00
publishDate: 2019-10-05T18:20:00+00:00
summary: A guide to configuring a static web server using Lighttpd on CentOS 7
description: A guide to configuring a static web server using Lighttpd on CentOS 7
tags:
- archived
- linux
- self-host
- sysadmin-devops
---

{{< details-toc >}}

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## Overview

A guide to configuring a static web server using Lighttpd on CentOS 7

## Note

This is currently in ‘recipe’ format and doesn’t explain why or go into depth.
Future plan for this doc is to be more detailed in those areas.

## What you get

* Web Server
  * Static virtual hosting
  * Let’s Encrypt SSL certificates
* Admin
  * Some attack reduction and blocking

## Not in this document

### Future work

* Add alternate path for web app support (e.g. CGI, uwSGI, etc).

### Out of scope (i.e. lots of other documentation sources for these)

* Initial host/instance setup
* General admin utilities and convenience setup

## Prerequisites

* An internet accessible host
* DNS Service (such as easydns.ca, self-hosted, etc)
* For this HOWTO: CentOS 7, 1 GiB RAM, 10 GiB HD (e.g. virtual HD)
* Repos
  * Defaults + EPEL (to install epel do yum install epel-release)

## Packages

The following packages need to be installed for this setup
(e.g. yum install package1 package2 ...)

### Admin tools

* policycoreutils
* policycoreutils-python
* rsync

### Web server

* httpd-tools
* lighttpd

### Let’s Encrypt / ACME SSL certificates

* certbot

### Attack detection / blocking

* fail2ban
* fail2ban-firewalld
* fail2ban-server

## First steps

1. Configure networking,admin users etc for your host/instance
2. (Optional) Install your preferred admin/monitoring utilities
etc.
3. Install “Admin Tools” listed above
4. Add ‘EPEL’ repository listed above

## Web server & Let’s Encrypt configuration

If you are not serving web pages or apps other Certbot configuration might be
more suitable for getting Let’s Encrypt SSL certificates for your mail server.

### Web server (HTTP: only serves ACME / Let’s Encrypt verification)

1. Install “Web Server” packages above
2. In file /etc/lighttpd/lighttpd.conf
    1. below
       ``var.vhosts_dir = server_root + "/vhosts"``
       add
       ``var.vhosts_acme_dir = server_root + "/vhosts-acme"``
    2. At end, add:

       ```conf
       $HTTP["scheme"] == "http" {
           include "/etc/lighttpd/vhosts-acme.d/*.conf"
       }
       ```

3. Configure IP binding
    1. Uncomment the server.bind = "localhost" line and
    replace localhost with your hostname (e.g.
    example.com)
    2. Below it add ``$SERVER["socket"] == "0.0.0.0:80" { }``.
       Optionally replace 0.0.0.0 with your ipv4 address.
4. In file, /etc/lighttpd/conf.d/dirlisting.conf
    1. set dir-listing.activate to "disable"
       (unless you want a browse-able list of files and
       directories for directories without an index file).
5. In file, /etc/lighttpd/modules.conf
    1. inside the directive server.modules =, uncomment or add the
    following:
        * mod_alias,
        * mod_redirect,
    2. if you want to redirect example.com to [www.example.com](http://www.example.com), after the closing parentheses for server-modules add

       ```conf
       $HTTP["scheme"] == "http" {
           $HTTP["host"] == "example.com" {
               url.redirect = (".*" => "http://www.example.com$0")
           }
       }
       ```

    3. Uncomment include "conf.d/compress.conf"
    4. Execute ``mkdir -p /var/cache/lighttpd/compress``
    5. Perform ``restorecon -Rv /var/cache/lighttpd``
6. For each static virtual host to serve, under
/etc/lighttpd/vhosts-acme.d/ include a file such as
www.example.com.conf (**NB**: The filename must end in .conf):

   ```conf
   $HTTP["host"] == "www.example.com" {
       var.server_name = "www.example.com"
       server.name = server_name

       server.document-root = vhosts_acme_dir + "/www.example.com"
       accesslog.filename = log_root + "/" + server_name + "/access.log"
   }
   ```

7. Issue ``setsebool -P httpd_setrlimit`` on
8. In /etc/lighttpd/lighttpd.conf set server.max-connections=512
   or set
   server.max-fd=2048 (depending on traffic and resources)
9. Run ``lighttpd-angel -t -f /etc/lighttpd/lighttpd.conf`` and correct any errors detected.
10. Execute ``systemctl restart lighttpd``
11. Do ``systemctl enable --now lighttpd``

### Web server (HTTPS: the real servers; requires SSL)

*Prerequisites*: Installed and configured web server as above.

#### Let’s encrypt (Part 1)

1. Install “Let’s Encrypt” package above (certbot)
2. Add certbot user and group

   ```sh
   adduser -U --system -M certbot
   passwd -l certbot
   ```

3. Add renew-hooks deploy script directory

   ```sh
   mkdir -p /etc/letsencrypt/renewal-hooks/deploy && chown -R certbot:certbot /etc/letsencrypt
   ```

4. Place the following script in /etc/letsencrypt/renewal-hooks/deploy
as lighttpd and make it executable
   **NOTE** With newer lighttpd this is not required as lighttpd now supports separate certificate and key files

   ```sh
   #!/bin/sh
    RET=0
    for CERTBOT_DOMAIN in $RENEWED_DOMAINS; do
        cd /etc/letsencrypt/live/${CERTBOT_DOMAIN} && cat fullchain.pem privkey.pem >lighttpd.pem && chmod 640 lighttpd.pem || RET=1
    done
    exit $RET
    ```

5. Place the following script in /etc/cron.daily as certbot and make it executable

   ```sh
   #!/bin/sh

   /bin/su -c "certbot -q -n renew" certbot
   ```

6. Issue ``mkdir -p /var/lib/letsencrypt && chown certbot:certbot /var/lib/letsencrypt``
7. Do ``mkdir -p /var/log/letsencrypt && chown certbot:adm /var/log/letsencrypt``
8. Perform certbot register

#### Lighttpd configuration (Part 2)

1. Create ACME / Let’s Encrypt verification directories (these will
be internet accessible from per-vhost directories down (e.g. www.example.com in the example below will be the web root))

   ```sh
   mkdir -p /var/www/vhosts-acme/www.example.com/.well-known
   chown -R certbot:certbot /var/www/vhosts-acme/www.example.com/.well-known
   ```

2. Repeat for each vhost you want to enable
3. Issue

   ```sh
   firewall-cmd --add-service http
   firewall-cmd --add-service https
   firewall-cmd --runtime-to-permanent
   ```

#### Let’s Encrypt (Part 2)

1. Issue

   ```sh
   su - certbot

   certbot certonly --staging --webroot -w /var/www/vhosts-acme/www.example.com -d www.example.com -d example.com
   ```

2. If the command completes successfully, repeat the certbot
command, without --staging.
3. Issue

   ```sh
   cd /etc/letsencrypt/live/\<default-domain> # In the example above \<default-domain> is www.example.com

    cat fullchain.pem privkey.pem >lighttpd.pem
    chmod 640 lighttpd.pem
    exit
    ```

    Note that Certbot recommendation is to put all hostnames on one
    certificate (see certbot --help --webroot for more information),
    unless one has specific reasons for having separate certificates.
    If you need separate certificates than you will need to issue the
    commands above for each certificate or set of certificates.

#### Lighttpd configuration (Part 3)

1. In /etc/lighttpd/lighttpd.conf, before

   ```conf
   $HTTP["scheme"] == "http" {
       include "/etc/lighttpd/vhosts-acme.d/*.conf"
   }
   ```

   which you added previously, add

   ```conf
   $SERVER["socket"] == "0.0.0.0:443" { include "ssl.conf" }
   $SERVER["socket"] == "[::]:443" { include "ssl.conf" }
   ```

2. Add a file /etc/lighttpd/ssl.conf that looks like:

   ```conf
   ssl.engine = "enable"
   ssl.pemfile = "/etc/letsencrypt/live/www.example.com/lighttpd.pem"
   include "/etc/lighttpd/vhosts.d/*.conf"
   ```

3. And add a file /etc/lighttpd/vhosts.d/www.example.com.conf for
each virtual host you are adding (in this case www.example.com)
that looks like:

   ```conf
   $HTTP["host"] == "www.example.com" {
       var.server_name = "www.example.com"
       server.name = server_name
       server.document-root = vhosts_dir + "/www.example.com"
       accesslog.filename = log_root + "/" + server_name + "/access.log"
   }
   ```

4. In file /etc/lighttpd/modules.conf
    1. inside the directive server.modules =, uncomment or add the
    following

       ```conf
       "mod_openssl",
       ```

    2. And if you want to use HTTP authentication for some pages or
    sites, also uncomment or add the following
        * ``"mod_auth",``
        * ``"mod_authn_file",``
    3. If you want to redirect HTTP to HTTPS, before

       ```conf
       $HTTP["scheme"] == "http" {
            $HTTP["host"] == "example.com" {
                 url.redirect = (".*" => "http://www.example.com$0")
            }
       }
       ```

       which you added above, add

       ```conf
       $HTTP["scheme"] == "http" {
           $HTTP["host"] == "example.com" {
               url.redirect = (".*" => "https://www.example.com$0")
           }
       }
       ```

       and after, add

       ```conf
       $HTTP["scheme"] == "http" {
           $HTTP["url"] !~ "^/.well-known/acme-challenge/" {
               $HTTP["host"] =~ ".*" {
                   url.redirect = ( "^/(.*)" => "https://%0/$1" )
               }
           }
       }
       ```

5. If you uncommented/added an mod_auth* line, make sure
/etc/lighttpd/conf.d/auth.conf is all commented out
6. If you want to require HTTP authentication for a page or site
   1. in /etc/vhosts.d/\<host-to-require-auth>, above the closing
      brace (}) in the \<host>.conf listed previously, add something similar to:

      ```conf
      auth.backend = "htdigest"
      auth.backend.htdigest.userfile = "/etc/lighttpd/users/\<host>"
      auth.require = ( "/" =>
                       (
                           "method" => "digest",
                           "realm" => "[auth-realm]",
                           "require" => "valid-user"
                       )
      )
      ```

   2. Use htdigest to create /etc/lighttpd/users/\<host> (man htdigest for details)
7. Do mkdir -p /var/www/vhosts/www.example.com for each static
vhost you are creating.

### DNS Setup

* Add a DNS A record for your ‘base hostname’ (e.g. for example.com
with \<your-ip>).
* Add a DNS CNAME record for any virtual hosts (e.g. for
[www.example.com](http://www.example.com) add
a CNAME record pointing to example.com)
* Your bare domain name (e.g. example.com) should be A or AAAA
records and
not CNAMEs. This also helps if you move some subdomains, or the
top level domain and some subdomains to services like Netlify.

## Attack detection/blocking

1. Install “Attack Detection/Blocking” packages listed above
2. Create /etc/fail2bain/jail.local like the following:

   ```ini
   [sshd]
   port = ssh,\<your-alternate-ssh-port-if-applicable> filter = sshd-aggressive enabled = true

   [selinux-ssh]
   port = ssh, enabled = true

   [lighttpd-auth]
   enabled = true

   [recidive]
   enabled = true
   ```

3. Run touch /var/log/fail2ban.log
4. And finally execute ``systemctl enable --now fail2ban``
