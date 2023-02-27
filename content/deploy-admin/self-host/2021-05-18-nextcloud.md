---
slug: nextcloud
aliases:
    - /docs/sysadmin-devops/self-host/nextcloud/
    - /sysadmin-devops/self-host/nextcloud/
    - /deploy-admin/nextcloud/
    - /docs/deploy-admin/self-host/nextcloud/
title: "Hosting a local Nextcloud"
date: 2021-05-18T14:16:25-04:00
publishDate: 2021-05-20T07:32:04-04:00
tags:
- cloud
- linux
- self-host
- sysadmin-devops
summary: "Setting up your own local Nextcloud can be useful for a number of reasons."
description: "Setting up your own local Nextcloud can be useful for a number of reasons."
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

Setting up your own local Nextcloud can be useful for a number of reasons. The author of this article is interested in using the fantastic file syncing capabilities without putting his data on an server accessible from the public internet.  For others what might be of interest is having truly private calendar and contacts that sync between devices, or perhaps using the 'Note' application on a private network.

Since we are using [Ubuntu Server 20.04](https://ubuntu.com/download/server/) we could get an all-in-one Nextcloud install by using the 'snap' from the 'Snap Store'. The author, however, has used the snap and finds he prefers to make his own choices about how to configure and set up Nextcloud. In addition, since the author has already set up a PostgreSQL server on a Pi as in the [PiSQL](2021-05-11-pisql.md) guide, he wants to use that server for Nextcloud as well. Finally, the redis server that is set up with this guide, will be shared with the [Gitea Pi](2021-05-13-gitea-pi.md) instance he has configured (and it in turn also uses the PiSQL server).

### Configure the host server

For that you can follow a guide such as [Intel NUC(-like) server](2021-05-18-intel-nuc-like-server.md) or [Raspberry Pi OS for a server](2020-09-08-raspberry-pi-os-for-a-server.md) on at least Pi 2 (older Pi's a definitely not powerful enough and likely you need at least a Pi 3 for good results). Another option is to use [Ubuntu server for Raspberry Pi](https://ubuntu.com/download/raspberry-pi) on at least a Pi 2.

### Install OS packages for Nextcloud support

```bash
sudo apt update
sudo apt install -y postgresql-client nginx redis php7.4-fpm \
php7.4-gd php7.4-pgsql php7.4-curl php7.4-mbstring php7.4-intl \
php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip php7.4-imap \
php-redis php-imagick ffmpeg libreoffice-core-nogui libreoffice-calc-nogui \
libreoffice-impress-nogui libreoffice-math-nogui libreoffice-draw-nogui \
smbclient
```

### Configure PHP PostgreSQL

Edit ``/etc/php/7.4/mods-available/pgsql.ini`` so it contains the following settings:

```ini
# configuration for php pgsql module
extension=pgsql.so

[PostgresSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
```

And enable the modules for use by PHP-FPM

```bash
sudo phpenmod pgsql pdo_psql
```

### Create and install SSL certificates for this server

1. Create internal SSL CA and server certificate and key by following the [Using XCA to create private SSL certificates](../sysadmin-devops/2021-05-11-using-xca-to-create-private-ssl-certificates.md) article. (As with the [PiSQL](2021-05-11-pisql.md) article, we require server certificates for the server (e.g. ``nextcloud.example.com``); this time we do not need to generate a CA (Certificate Authority) but can use the existing one).
2. We also need to generate a 'client' certificate for this host, which uses the same procedure, except that instead of selecting the '\[default] TLS_server' template, we select the '\[default] TLS_client' template. For the client certificate I recommend using a name such as ``nextclouddb`` for the CN — you can still add this server's DNS name(s) as Subject Alternative Names (x509v3 SAN).  Note that on the client certificate at one SAN and/or the CN must be the username nextcloud uses to connect to the database.

Assuming you have copied your client nextclouddb.crt and nextclouddb.pem to your admin user, as well as the ca certificate (which we will call 'root.crt'), and that you are currently in your admin user account:

1. ``sudo mkdir /var/www/.postgresql``
2. ``sudo cp nextclouddb* root.crt /var/www/.postgresql``
3. ``sudo chown root:www-data /var/www/.postgresql/nextclouddb* /var/www/.postgresql/root.crt``
4. You can now remove the client cert and key from your admin user account: ``rm nextclouddb*``
5. ``cd /var/www/.postgresql``
6. ``chmod 750 .``
7. ``mv nextclouddb.crt postgresql.crt``
8. ``mv nextclouddb.pem postgresql.key``
9. ``cp root.crt /usr/local/share/ca-certificates/ca-private.gitea.internal.com``
10. ``update-ca-certificates``
11. ``cd ..``

**NB** Keep this session open, we'll come back to it

#### On the database server, create user and database for Nextcloud

1. Login as your admin user to your database server
2. ``sudo su - postgres``
3. ``createuser -P nextclouddb``
4. Enter a new strong password when prompted (you will need to enter it twice).
5. For C.UTF-8 below substitute the appropriate UTF-8 locale:

   ```bash
   createdb -O nextclouddb --encoding UTF8 --locale C.UTF-8 --template template1 nextclouddb
   ```

6. ``exit``
7. ``exit``

#### Back on the Nextcloud server, test DB connection

In the session as user ``www-data`` from above and assuming your db server is named ``nextcloud.example.com``:

```bash
psql "postgres://nextclouddb@pisql.example.com/nextclouddb?sslmode=verify-full"
```

Enter the database user's password when prompted, and you should get a standard 'psql' prompt, such as:

```bash
psql (11.12 (Raspbian 11.12-0+deb10u1), server 11.11 (Raspbian 11.11-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

nextclouddb=>
```

Enter ``\l`` to see the list of databases, and ``\q`` to quit.

## Obtain and install Nextcloud

### Download Nextcloud and verification information

1. Download Nextcloud tarball (e.g. ``wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2``)
2. Download SHA256 for tarball (e.g. ``wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2.sha256``)
3. Download GPG signature for tarball (e.g. ``wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2.asc``
4. Download GPG key (e.g. ``wget https://nextcloud.com/nextcloud.asc``)

### Verify the downloads

1. ``sha256sum --ignore-missing -c nextcloud-21.0.1.tar.bz2.sha256``
   1. Should report 'OK'
2. ``gpg --import nextcloud.asc``
3. ``gpg --verify nextcloud-21.0.1.tar.bz2.asc nextcloud-21.0.1.tar.bz2``
   1. Should report 'Good signature from "Nextcloud Security \<security@nextcloud.com>" \[unknown]'
4. ``gpg --keyserver keyserver.ubuntu.com --recv-keys D75899B9A724937A``
   1. Should report '1 processed, 1 unchanged`
5. You no longer require the \*.sha256 or \*.asc files.

### Prepare your installation location

If you plan on storing Nextcloud and/or it's data on external storage, prepare the storage and mountpoints now.

* Nextcloud needs to be mounted on ``/var/www/nextcloud``
* The data defaults to being located in ``/var/www/nextcloud/data`` but that is configurable, and it is recommended that it be moved. You might want to try ``/srv/nextcloud-data``

### Extract Nextcloud

``sudo tar -C /var/www/ -xvjf nextcloud-21.0.1.tar.bz2``

### Copy your server certificates in place

``sudo mkdir /etc/ssl/nginx``
``sudo cp nextcloud.example.com.* /etc/ssl/nginx/``
``sudo chmod 600 /etc/ssl/nginx/nextcloud.example.com.key``

### Create an Nginx configuration

Copy the following to ``/etc/nginx/sites-available/nextcloud`` and modify as appropriate.

```nginx
upstream php-handler {
    #server 127.0.0.1:9000;
    server unix:/var/run/php/php7.4-fpm.sock;
}

server {
    listen 80;
    listen [::]:80;
    server_name nextcloud.example.com;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name cloud.example.com;

    # Use Mozilla's guidelines for SSL/TLS settings
    # https://mozilla.github.io/server-side-tls/ssl-config-generator/
    ssl_certificate     /etc/ssl/nginx/nextcloud.example.com.crt;
    ssl_certificate_key /etc/ssl/nginx/nextcloud.example.com.key;

    # HSTS settings
    # WARNING: Only add the preload option once you read about
    # the consequences in https://hstspreload.org/. This option
    # will add the domain to a hardcoded list that is shipped
    # in all major browsers and getting removed from this list
    # could take several months.
    #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # Pagespeed is not supported by Nextcloud, so if your server is built
    # with the `ngx_pagespeed` module, uncomment this line to disable it.
    #pagespeed off;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    add_header Referrer-Policy                      "no-referrer"   always;
    add_header X-Content-Type-Options               "nosniff"       always;
    add_header X-Download-Options                   "noopen"        always;
    add_header X-Frame-Options                      "SAMEORIGIN"    always;
    add_header X-Permitted-Cross-Domain-Policies    "none"          always;
    add_header X-Robots-Tag                         "none"          always;
    add_header X-XSS-Protection                     "1; mode=block" always;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;

    # Path to the root of your installation
    root /var/www/nextcloud;

    # Specify how to handle directories -- specifying `/index.php$request_uri`
    # here as the fallback means that Nginx always exhibits the desired behaviour
    # when a client requests a path that corresponds to a directory that exists
    # on the server. In particular, if that directory contains an index.php file,
    # that file is correctly served; if it doesn't, then the request is passed to
    # the front-end controller. This consistent behaviour means that we don't need
    # to specify custom rules for certain paths (e.g. images and other assets,
    # `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
    # `try_files $uri $uri/ /index.php$request_uri`
    # always provides the desired behaviour.
    index index.php index.html /index.php$request_uri;

    # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Make a regex exception for `/.well-known` so that clients can still
    # access it despite the existence of the regex rule
    # `location ~ /(\.|autotest|...)` which would otherwise handle requests
    # for `/.well-known`.
    location ^~ /.well-known {
        # The rules in this block are an adaptation of the rules
        # in `.htaccess` that concern `/.well-known`.

        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        # Let Nextcloud's API for `/.well-known` URIs handle all other
        # requests by passing them to the front-end controller.
        return 301 /index.php$request_uri;
    }

    # Rules borrowed from `.htaccess` to hide certain paths from clients
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

    # Ensure this block, which passes PHP files to the PHP process, is above the blocks
    # which handle static assets (as seen below). If this block is not declared first,
    # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
    # to the URI, resulting in a HTTP 500 error response.
    location ~ \.php(?:$|/) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;

        try_files $fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;

        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
        fastcgi_param front_controller_active true;     # Enable pretty urls
        fastcgi_pass php-handler;

        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ \.(?:css|js|svg|gif)$ {
        try_files $uri /index.php$request_uri;
        expires 6M;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    location ~ \.woff2?$ {
        try_files $uri /index.php$request_uri;
        expires 7d;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    # Rule borrowed from `.htaccess`
    location /remote {
        return 301 /remote.php$request_uri;
    }

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
}
```

### Configure Nginx

1. Disable default 'website'
   1. ``sudo rm /etc/nginx/sites-enabled/default``
2. Enable Nextcloud configuration
   1. ``sudo ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/nextcloud``

### Restart Nginx

``systemctl restart nginx``

## Use the installation wizard (first login)

Or the command line tool (occ).  For more details see [installation wizard](https://docs.nextcloud.com/server/latest/admin_manual/installation/installation_wizard.html) or [installing from the command line](https://docs.nextcloud.com/server/latest/admin_manual/installation/command_line_installation.html).

### Login

Once you have a successful configuration I recommend a test login. In addition, it would be a good idea to enable "Server-side Encryption" in "Settings". (Only if you do not have full disk encryption enabled, otherwise the system will get too slow).

## Additional configuration

### Setup a Fail2Ban filters and jails

1. In ``/etc/fail2ban/filter.d/nextcloud.conf`` add:

   ```conf
   [Definition]
   _groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
   failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
               ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
   datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
   ```

2. In ``/etc/fail2ban/jail.d/nextcloud.local`` add:

   ```ini
   [nextcloud]
   backend = auto
   enabled = true
   port = 80,443
   protocol = tcp
   filter = nextcloud
   maxretry = 3
   bantime = 86400
   findtime = 43200
   logpath = /srv/nextcloud-data/nextcloud.log
   ```

3. Add the following to ``/etc/fail2ban/jail.local``

   ```ini
   [nginx-http-auth]
   enabled = true

   [nginx-botsearch]
   enabled = true

   # Ban attackers that try to use PHP's URL-fopen() functionality
   # through GET/POST variables. - Experimental, with more than a year
   # of usage in production environments.

   [php-url-fopen]
   enabled = true  
   ```

4. Restart fail2ban: ``sudo systemctl restart fail2ban``
5. Verify all is well: ``sudo systemctl status -l fail2an``

### Configure Redis

``sudoedit /etc/redis.conf``

Uncomment the following lines:

```conf
unixsocket /run/redis/redis-server.sock
unixsocketperm 770
```

``sudo adduser www-data redis`` (to use the socket, above)

Add:

```conf
requirepass a-very-strong-password-obviously-not-what-you-see-here--you-have-been-warned
```

### Configure period tasks (cron)

``sudo crontab -u www-data -e``

Make sure the following line exists in the crontab

```crontab
*/5  *  *  *  * php -f /var/www/nextcloud/cron.php
```

Save and exit.

### Tune PHP-FPM

[PHP-FPM tuning advice in Nextcloud docs](https://docs.nextcloud.com/server/latest/admin_manual/installation/server_tuning.html#tune-php-fpm)

* Make sure you set ``memory_limit`` in ``/etc/php/7.4/fpm/php.ini`` to at least ``512M``. If you do not, you will have issues with sync at least.

### Configure default phone number locale

``sudoedit /var/www/nextcloud/config/config.php``

Add:

```python
'default_phone_region' => 'CA',
```

in the config ARRAY.

## Enjoy your private cloud

Just add users and files and other data...
