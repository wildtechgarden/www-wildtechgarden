---
slug: lightweight-public-git-self-hosting
aliases:
- /2020/12/19/lightweight-public-git-self-hosting/
- /post/lightweight-public-git-self-hosting/
- /deploy-admin/lightweight-public-git-self-hosting/
- /post/lightweight-git-self-hosting/
- /lightweight-public-git-self-hosting/
- /docs/development/git-github-gitea/lightweight-public-git-self-hosting/
- /sysadmin-devops/self-host/lightweight-public-git-self-hosting/
- /docs/deploy-admin/self-host/lightweight-public-git-self-hosting/
author: Daniel F. Dickinson
date: '2021-02-09T23:32:46+00:00'
publishDate: '2020-12-19T16:53:00+00:00'
summary: 'Public git self hosting can be desirable for a number of reasons. Here we discuss a very lightweight alternative.'
description: 'Public git self hosting can be desirable for a number of reasons. Here we discuss a very lightweight alternative.'
tags:
- archived
- git
- gitea
- linux
- self-host
- sysadmin-devops
title: "ARCHIVED: Lightweight public Git self hosting"
---

{{< details-toc >}}

## ARCHIVED

While this remains extremely lightweight it doesn't allow the use of features like git-lfs, nor does it include CI/CD options. For the for former you may want to investigate something like [Gitea](https://docs.gitea.io) and for both the former and the latter you may want to try something like [Source Hut](https://sourcehut.org). Gitea is lighter than Source Hut but is 'just' Git hosting / issue tracking etc and doesn't include CI/CD.

I have written an article about [Gitea on a Raspberry Pi](2021-05-13-gitea-pi) but now use Gitea in a docker container on [an Intel-NUC-like SBC as a server](2021-05-18-intel-nuc-like-server).

## Preface

Public git self hosting can be desirable for a number of reasons, but you may not want the expense and maintenance burden of a GitLab or other ‘full-service’ git hosting option, so this article discusses a lightweight option for a browsing or cloning your git repositories via HTTP/HTTPS (web), as well as pushing, pulling, cloning, etc using SSH.

At the very least it gives you a way to keep a backup which you control, of your valuable source code and documents that are also on a large central service.

**CAVEAT**: This article only covers a fully public hosting; if you want private
repositories as well, you will need to do more research and work.

Also, this article does not cover pushing to your repositories via HTTP(S).

## Prerequisites and assumptions

* A reasonably recent version of Debian or Ubuntu.
* A server to host the service on which is able to accept connections from all the hosts you wish to serve. I use a VPS on [OVHcloud](https://ca.ovh.com/manager/).
* Have Apache2 installed with SSL enabled (that is this article is not going to cover enabling SSL; using a tool like [Certbot for Let’s Encrypt](https://certbot.eff.org) is recommended).
* Enough fast enough storage for your repositories.
* An SSH key for the Gitolite administrator: If you don’t have one, see the [additional information](#additional-information) section of this page.
* A workstation with SSH and Git.
* (Optional) Preexisting repositories you want to include on this public server.
* Assumes that the Gitweb will be installed to be used from the root of an Apache virtual host (e.g. that <https://git.example.com> would be your git server, if you configure your server to respond to ‘git.example.com’, possibly in addition to other names).

## Installation and configuration

### Install the packages

1. ```sh
   sudo apt install apache2 apache2-utils git-core gitolite gitweb highlight
   ```

2. You will be prompted for the Gitolite admin’s SSH public key; paste the admin SSH key into the dialogue when prompted.
3. Make sure gitweb is disabled until ready to use it: ``sudo a2disconf gitweb && sudo systemctl reload apache2``

### Configure Gitolite

1. Edit ``/etc/gitolite3/gitolite.rc`` as needed for your situation. For example:

   ```perl
   # configuration variables for gitolite
   # This file is in perl syntax. But you do NOT need to know perl to edit it --
   # just mind the commas, use single quotes unless you know what you're doing,
   # and make sure the brackets and braces stay matched up!
   # (Tip: perl allows a comma after the last item in a list also!)
   # HELP for commands can be had by running the command with "-h".
   # HELP for all the other FEATURES can be found in the documentation (look for
   # "list of non-core programs shipped with gitolite" in the master index) or
   # directly in the corresponding source file.
   %RC = (
       # ------------------------------------------------------------------
       # default umask (0077) gives you perms of '0700'; see the rc file docs for
       # how/why you might change this
       UMASK => 0022,
       # look for "git-config" in the documentation
       GIT_CONFIG_KEYS => 'gitweb.*',
       # comment out if you don't need all the extra detail in the logfile
       LOG_EXTRA => 1,
       # logging options
       # 1. leave this section as is for 'normal' gitolite logging (default)
       # 2. uncomment this line to log ONLY to syslog:
       # LOG_DEST => 'syslog',
       # 3. uncomment this line to log to syslog and the normal gitolite log:
       LOG_DEST => 'syslog,normal',
       # 4. prefixing "repo-log," to any of the above will **also** log just the
       # update records to "gl-log" in the bare repo directory:
       # LOG_DEST => 'repo-log,normal',
       # LOG_DEST => 'repo-log,syslog',
       # LOG_DEST => 'repo-log,syslog,normal',
       # syslog 'facility': defaults to 'local0', uncomment if needed. For example:
       # LOG_FACILITY => 'local4',
       # roles. add more roles (like MANAGER, TESTER, ...) here.
       # WARNING: if you make changes to this hash, you MUST run 'gitolite
       # compile' afterward, and possibly also 'gitolite trigger POST_COMPILE'
       ROLES => {
       READERS => 1,
       WRITERS => 1,
       },
       # enable caching (currently only Redis). PLEASE RTFM BEFORE USING!!!
       # CACHE => 'Redis',
       # ------------------------------------------------------------------
       # rc variables used by various features
       # the 'info' command prints this as additional info, if it is set
       # SITE_INFO => 'Please see http://blahblah/gitolite for more help',
       # the CpuTime feature uses these
       # display user, system, and elapsed times to user after each git operation
       DISPLAY_CPU_TIME => 1,
       # display a warning if total CPU times (u, s, cu, cs) crosses this limit
       # CPU_TIME_WARN_LIMIT => 0.1,
       # the Mirroring feature needs this
       # HOSTNAME => "",
       # TTL for redis cache; PLEASE SEE DOCUMENTATION BEFORE UNCOMMENTING!
       # CACHE_TTL => 600,
       # ------------------------------------------------------------------
       # suggested locations for site-local gitolite code (see cust.html)
       # this one is managed directly on the server
       # LOCAL_CODE => "$ENV{HOME}/local",
       # or you can use this, which lets you put everything in a subdirectory
       # called "local" in your gitolite-admin repo. For a SECURITY WARNING
       # on this, see http://gitolite.com/gitolite/non-core.html#pushcode
       # LOCAL_CODE => "$rc{GL_ADMIN_BASE}/local",
       # ------------------------------------------------------------------
       # List of commands and features to enable
       ENABLE => [
           # COMMANDS
           # These are the commands enabled by default
           'help',
           'desc',
           'info',
           'perms',
           'writable',
           # Uncomment or add new commands here.
           # 'create',
           # 'fork',
           # 'mirror',
           # 'readme',
           # 'sskm',
           # 'D',
           # These FEATURES are enabled by default.
           # essential (unless you're using smart-http mode)
           'ssh-authkeys',
           # creates git-config entries from gitolite.conf file entries like 'config foo.bar = baz'
           'git-config',
           # creates git-daemon-export-ok files; if you don't use git-daemon, comment this out
           # 'daemon',
           # creates projects.list file; if you don't use gitweb, comment this out
           'gitweb',
           # These FEATURES are disabled by default; uncomment to enable. If you
           # need to add new ones, ask on the mailing list :-)
           # user-visible behaviour
           # prevent wild repos auto-create on fetch/clone
           'no-create-on-read',
           # no auto-create at all (don't forget to enable the 'create' command!)
           'no-auto-create',
           # access a repo by another (possibly legacy) name
           # 'Alias',
           # give some users direct shell access. See documentation in
           # sts.html for details on the following two choices.
           # "Shell $ENV{HOME}/.gitolite.shell-users",
           # 'Shell alice bob',
           # set default roles from lines like 'option default.roles-1 = ...', etc.
           # 'set-default-roles',
           # show more detailed messages on deny
           # 'expand-deny-messages',
           # show a message of the day
           # 'Motd',
           # system admin stuff
           # enable mirroring (don't forget to set the HOSTNAME too!)
           # 'Mirroring',
           # allow people to submit pub files with more than one key in them
           # 'ssh-authkeys-split',
           # selective read control hack
           # 'partial-copy',
           # manage local, gitolite-controlled, copies of read-only upstream repos
           # 'upstream',
           # updates 'description' file instead of 'gitweb.description' config item
           # 'cgit',
           # allow repo-specific hooks to be added
           # 'repo-specific-hooks',
           # performance, logging, monitoring...
           # be nice
           'renice 10',
           # log CPU times (user, system, cumulative user, cumulative system)
           'CpuTime',
           # syntactic_sugar for gitolite.conf and included files
           # allow backslash-escaped continuation lines in gitolite.conf
           'continuation-lines',
           # create implicit user groups from directory names in keydir/
           # 'keysubdirs-as-groups',
           # allow simple line-oriented macros
           # 'macros',
           # Kindergarten mode
           # disallow various things that sensible people shouldn't be doing anyway
           # 'Kindergarten',
       ],
   );
   # ------------------------------------------------------------------------------
   # per perl rules, this should be the last line in such a file:
   1;
   # Local variables:
   # mode: perl
   # End:
   # vim: set syn=perl:
   ```

   * In particular the UMASK setting is needed for the Gitweb integration.
   * Also, as this is a public server, I recommend, as in this example, disabling automatic creation of repositories on clone/fetch, and in fact of any automatic creation of repositories.

2. For a summary of day-to-day admin tasks see the [administration tasks section of the official Gitolite Documentation](https://gitolite.com/gitolite/fool_proof_setup#administration-tasks)

   * Create any users you need

3. In the gitolite-admin directory you cloned while following the above documentation, edit conf/gitolite.conf to add the repositories you want to include. For example:

   ```perl
   ### DO NOT USE WITHOUT EDITING!! ###
   repo gitolite-admin
     RW+ = admin
     - = @all
   #repo testing
   #  RW+ = @all
   #  R = gitweb
   @active = \
   docker/docker-armel-cross-compile-wheezy \
   linux-kernel/torvalds-linux \
   linux-kernel/wm8650-configs \
   linux-kernel/wm8650-gpl-reference-kernel \
   linux-kernel/wm8650-gpl-reference-kernel-build \
   linux-kernel/wm8650-kernel \
   packages/wingtk-gvsbuild \
   packages/zim-desktop-wiki-zim-desktop-wiki \
   admin/ansible-sample-for-rpi-article

   @archived = \
   docker/docker-dovecot \
   docker/docker-lighttpd \
   openembedded/meta-cshored

   repo @archived
     config gitweb.owner = A User
     config gitweb.description = UNMAINTAINED
     R = @all

   repo @active
     config gitweb.owner = A User
     RW+ = user1
     R = @all

   repo docker/.*
     config gitweb.description = UNMAINTAINED - Dockerfile and support for creating docker container

   repo docker/docker-armel-cross-compile-wheezy
     config gitweb.description = Dockerfile for ARM HF cross compile of armel on Debian Wheezy

   repo linux-kernel/torvalds-linux
     config gitweb.description = Fork of git.kernel.org mainline with a number of other Linux kernel project as branches against mainline
     config gitweb.blame = 0
     config gitweb.pickaxe = 0
     config gitweb.snapshot = ''

   repo linux-kernel/wm8650-configs
     config gitweb.description = WM8650 WonderMedia for Craig CLP281 Linux 2.6.32.9 and some Android kernel configs

   repo linux-kernel/wm8650-gpl-reference-kernel
     config gitweb.description = UNMAINTAINED - WM8650 WonderMedia for Craig CLP281 Linux 2.6.32.9 and some Android kernel from tarball
     config gitweb.blame = 0
     config gitweb.pickaxe = 0
     config gitweb.snapshot = '' repo linux-kernel/wm8650-gpl-reference-kernel-build
     config gitweb.description = Build system for WM8650 WonderMedia for Craig CLP281 Linux 2.6.32.9 and some Android kernel repo linux-kernel/wm8650-kernel
     config gitweb.description = WM8650 WonderMedia for Craig CLP281 Linux 2.6.32.9 and some Android kernel config gitweb.blame = 0
     config gitweb.pickaxe = 0
     config gitweb.snapshot = ''

   repo admin/ansible-sample-for-rpi-article
     config gitweb.description = Sample Ansible config for an article on www.danielfdickinson.ca
   ```

   * This example has gitolite-admin fully managed by the gitolite admin SSH key (keydir/admin.pub) and prohibits access by anyone else.
   * I generally group my repos in subdirectories (e.g. docker/*, linux-kernel/*, etc, but this is completely optional).
   * In this example, there are two groups of repositories aside from the gitolite-admin repository: @archived and @active.
   * I have made @archived read-only for all users (including public / anonymous access).
   * I have made @active fully read-write for user1 (keydir/user1.pub) and read-only for anyone else (including anonymous / public access).
   * In additional I have defined a default gitweb (see below) owner (just a descriptive string), and description for @archived repositories, and a default owner for @active repos.
   * For docker repos I have overridden the gitweb description.
   * For one specific docker repo docker/docker-armel-cross-compile-wheezy i have overridden the override to a specific description for that repo.
   * For torvalds-linux and another kernel repo I have overridden certain gitweb settings that are CPU intensive (because the linux kernel is a large repo).

4. ``git add conf keydir``
5. ``git commit -m "Update gitolite configuration"``
6. ``git push``
   * This will apply the configuration and create any repositories (including subdirectories, if necessary) that don’t already exist.

### Set permission to allow Gitweb access to Gitolite repos

1. Change the permissions on /var/lib/gitolite3 to rx for all: ``sudo chmod ugo+rx /var/lib/gitolite3``
2. Change the permissions on /var/lib/gitolite3/projects.list to read for all: ``sudo chmod ugo+r /var/lib/gitolite3/projects.list``
3. Make sure /var/lib/gitolite3/repositories directory is rx for all: ``sudo chmod ugo+rx /var/lib/gitolite3/repositories``

**NB**: If you applied the configuration above (particularly the UMASK), before
creating any repositories that should be all you need to do permissions-wise.

### Configure Gitweb (including Apache 2 configuration)

#### Place static webserver giles

1. On your server create /var/www/gitweb/gitweb-local for some static files.
2. Place your site’s ‘favicon’ with the name /var/www/gitweb/gitweb-local/git-favicon.png.
3. If you want to have a custom header on every page served by gitweb, create a file
/var/www/gitweb/gitweb-local/siteheader.html such as:

   ```html
   <div class="site_header">
       <h1>A User's Git Repos</h1>
   </div>
   ```

4. Similarly for custom HTML to be placed below the breadcrumb trail on the
gitweb homepage (placed as /var/www/gitweb/gitweb-local/indextext.html:

   ```html
   <div class="homepage_text">
       <p>A's public repositories of interesting source.</p>
   </div>
   ```

5. If you want to modify the look of gitweb you can use a custom CSS file in
/var/www/gitweb/gitweb-local/gitweb.css such as:

  ```css
   @media not speech {
   body {
       font-size: 16px;
     }
   }
   @media screen and (min-width: 28em) {
     body {
        font-size: 17px;
      }
   }
   @media screen and (min-width: 36em) {
   body {
         font-size: 18px;
      }
   }
   @media screen and (min-width: 48em) {
     body {
        font-size: 19px;
      }
   }
   @media screen and (min-width: 56em) {
     body {
        font-size: 20px;
      }
   }
   @media screen and (min-width: 64em) {
     body {
         font-size: 21px;
     }
   }
   div.site_header {
     background-color: #d9d8d1;
     margin-bottom: .2em;
     padding: .4em;
     text-align: center;
   }
   div.page_header {
     margin-bottom: .2em;
     padding-bottom: .4em;
     padding-top: .2em;
   }
   div.site_header h1 {
     margin: 0;
   }
   ```

#### Create a virtual host configuration

Create an Apache virtual host configuration in
/etc/apache2/sites-available/git.example.com.conf:

(this config assumes use of HTTPS only, and of Let’s Encrypt certificates)

```conf
Define _DOMAIN example.com
Define _HOST git.${_DOMAIN}

<IfModule mod_ssl.c>
  <VirtualHost *:443>
      ServerName ${_HOST}
      ServerAdmin gitadmin@${_DOMAIN}

      DocumentRoot /var/lib/gitolite3/repositories
      ErrorLog ${APACHE_LOG_DIR}/git.example.com-error.log
      CustomLog ${APACHE_LOG_DIR}/git.example.com-access.log combined

      Alias /gitweb /usr/share/gitweb
      Alias /gitweb-local /var/www/gitweb/gitweb-local
      <Directory /usr/share/gitweb/gitweb.cgi>
        SSLOptions +StdEnvVars
        Options +ExecCGI
        AddHandler cgi-script .cgi
      </Directory>
      <Directory /var/www/gitweb/gitweb-local>
        SetHandler default-handler
        Require all granted
      </Directory>
      SetEnv GIT_HTTP_EXPORT_ALL
      SetEnv GIT_PROJECT_ROOT /var/lib/gitolite3/repositories
      <LocationMatch "(?x)^/(((.*)(.git)|(.+))(/)?(HEAD |
        info/refs |
        objects/(info/[^/]+ |
        [0-9a-f]{2}/[0-9a-f]{38} |
        pack/pack-[0-9a-f]{40}.(pack|idx)) |
        git-upload-pack))$">
            Require all granted
      </LocationMatch>
      ScriptAliasMatch
        "(?x)^/(((.*)(.git)|(.+))(/)?(HEAD |
        info/refs |
        objects/(info/[^/]+ |
        [0-9a-f]{2}/[0-9a-f]{38} |
        pack/pack-[0-9a-f]{40}.(pack|idx)) |
        git-upload-pack))$"
            /usr/lib/git-core/git-http-backend/$3$5$6$7

      <Directory /usr/lib/git-core/git-http-backend>
        SSLOptions +StdEnvVars
        Options +ExecCGI +FollowSymLinks
      </Directory>
      <Directory /usr/lib/git-core/git-upload-pack>
        SSLOptions +StdEnvVars
        Options +ExecCGI +FollowSymLinks
      </Directory>
      <Directory /var/lib/gitolite3/repositories/>
        Require all granted
      </Directory>
      # turning on mod rewrite
      RewriteEngine on
      # make the front page an internal rewrite to the gitweb script
      RewriteRule ^/$ /usr/share/gitweb/gitweb.cgi
      # SSL Engine Switch:
      # Enable/Disable SSL for this virtual host.
      SSLEngine on
      <FilesMatch ".(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
      </FilesMatch>
      SSLCertificateFile /etc/letsencrypt/live/${_HOST}/fullchain.pem
      SSLCertificateKeyFile /etc/letsencrypt/live/${_HOST}/privkey.pem
      Include /etc/letsencrypt/options-ssl-apache.conf
    </VirtualHost>
</IfModule>
# insecure access redirects to secure
<VirtualHost *:80>
  ServerName ${_HOST}
  ServerAdmin gitadmin@${_DOMAIN}
  DocumentRoot /var/lib/gitolite3/repositories
  # avoid Let's Encrypt validation path
  RedirectMatch permanent ^(?!/.well-known/acme-challenge)(.*) https://${_HOST}/$1

  CustomLog ${APACHE_LOG_DIR}/redirect.log vhost_combined
  RewriteEngine on
  RewriteCond %{SERVER_NAME} =${_HOST}
  RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
UnDefine _HOST
UnDefine _DOMAIN
```

#### Configure gitweb.conf

Edit /etc/gitweb.conf to suit your needs. For example:

```perl
# path to git projects (<project>.git)
$projectroot = "/var/lib/gitolite3/repositories";
# directory to use for temp files
$git_temp = "/tmp";
$my_uri = "/";
# target of the home link on top of all pages
$home_link = $my_uri || "/";
# String for start of breadcrumb on top of all pages
$home_link_str = "*";
# html to include at top of every page
$site_header = "/var/www/gitweb/gitweb-local/siteheader.html";
# html to include at bottom of every page
#$site_footer = "/var/www/gitweb/gitweb-local/sitefooter.html";
# html text to include at home page
$home_text = "/var/www/gitweb/gitweb-local/indextext.html";
# file with project list; by default, simply scan the projectroot dir.
#$projects_list = $projectroot;
$projects_list = "/var/lib/gitolite3/projects.list";
# stylesheet to use
@stylesheets = qw(/gitweb/static/gitweb.css
 /gitweb-local/gitweb.css);
# javascript code for gitweb
$javascript = "/gitweb/static/gitweb.js";
# logo to use
$logo = "/gitweb/static/git-logo.png";
# the 'favicon'
$favicon = "/gitweb-local/git-favicon.png";
# git-diff-tree(1) options to use for generated patches
#@diff_opts = ("-M");
@diff_opts = ();
$strict_export = 1;
$maxload = 10;
$site_name = "Yet Another Git Server";
$per_request_config = sub {
  $ENV{GL_USER} = $cgi->remote_user || "gitweb";
};
#$projects_list_description_width = 25;
$omit_owner = 1;
#$feature{'pathinfo'}{'default'} = [0];
$feature{'blame'}{'default'} = [0];
$feature{'pickaxe'}{'default'} = [1];
$feature{'grep'}{'default'} = [1];
$feature{'highlight'}{'default'} = [1];
# Allow these options to be overridden on a per-repo basis
$feature{'snapshot'}{'override'} = 1;
$feature{'blame'}{'override'} = 1;
$feature{'pickaxe'}{'override'} = 1;
$feature{'grep'}{'override'} = 1;
$feature{'highlight'}{'override'} = 1;
$prevent_xss = 1;
@git_base_url_list = qw(https://git.example.com);
```

### Enable needed Apache 2 modules and virtual host

1. sudo a2enmod cgid
2. sudo a2enmod ssl
3. sudo a2ensite git.example.com

## Launch

* sudo systemctl restart apache2
* Browsing to git.example.com should now display your gitweb homepage, including a lists of projects currently on the server.
* Likewise you should be able to clone via HTTPS.

## Populate the repositories you created

Assuming you have preexisting repositories you are wanting to include on this public server, you can now copy them to this public server.

1. On your workstation clone the existing repo as a ‘bare repository’
   * ``git clone --bare <https://example.com/path/to/yourrepo>``
2. cd yourrepo
3. “Mirror” (make an identical copy of the repo) on your (new) public server:
   * ``git push --mirror gitolite3@example.org:yourrepo``

If you have many repositories to mirror you may wish to create a script to
automate the process.

## Additional information

* [How to Mirror a Git Repository](https://medium.com/cloud-native-the-gathering/how-to-mirror-copy-an-entire-existing-git-repository-into-a-new-one-3bb8faefad9e)
* [OVH’s Guide for SSH Key Generation](https://docs.ovh.com/gb/en/public-cloud/public-cloud-first-steps/#step-1-creating-ssh-keys)
* [Scaleway’s Guide for SSH Key Generation](https://www.scaleway.com/en/docs/console/my-project/how-to/create-ssh-key)
* [GitHub’s Guide for SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
* ~~[Oracle’s Guide for SSH]\(``https://docs.oracle.com/en/cloud/paas/database-dbaas-cloud/csdbi/generate-ssh-key-pair.html#GUID-4285B8CF-A228-4B89-9552-FE6446B5A673``)~~
* [Gitolite Official Website](https://gitolite.com/gitolite/)
* [Gitweb Configuration - gitweb.conf – Official](https://git-scm.com/docs/gitweb.conf)
* [Gitweb Configuration - gitweb – Official](https://git-scm.com/docs/gitweb)
* [Git HTTP backend configuration – Official](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-http-backend.html)
* ~~[Setup Git, Gitweb with git-http-backend]\(``https://www.tiktalk.com/posts/2013/05/03/setup-git-gitweb-with-git-http-backend-smart-http-on-ubuntu-12-04/``)~~
* [git, gitweb, and per-user repos](https://www.isi.edu/~calvin/gitweb.htm)
