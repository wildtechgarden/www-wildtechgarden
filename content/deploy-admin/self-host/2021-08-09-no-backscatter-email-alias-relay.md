---
slug: no-backscatter-email-alias-relay
aliases:
    - /docs/sysadmin-devops/self-host/no-backscatter-email-alias-relay/
    - /sysadmin-devops/self-host/no-backscatter-email-alias-relay/
    - /deploy-admin/no-backscatter-email-alias-relay/
    - /docs/deploy-admin/self-host/no-backscatter-email-alias-relay/
title: "No backscatter email alias relay"
date: 2021-08-09T06:26:09-0400
publishDate: 2021-08-09T06:26:09-0400
tags:
- backscatter
- linux
- security
- self-host
- sysadmin-devops
summary: "Setting up an email relay that aliases addresses in various domains to a specific offsite user doesn't have to mean backscatter. Here is one solution."
description: "Setting up an email relay that aliases addresses in various domains to a specific offsite user doesn't have to mean backscatter."
---

{{< details-toc >}}

## Preface

Setting up an email relay that aliases addresses in various domains to a specific offsite user doesn't have to mean backscatter. Here is one solution.

### What you get

* Redirect mail from certain domains you control (e.g. ``domain1.example.com`` and ``domain2.example.com``) to a specific user in another domain (for example ``you@example.net``) for any number of aliases in ``domain1.example.com`` and ``domain2.example.com``.
* Keep spam to a minimum (to the extent possible with a VPS with 1GB of RAM; better options are available with more RAM).
* Avoid backscatter even with maliciously crafted email intended to take advantage of the bounce mechanism when you use a relay and it rejects mail your server didn't.

### Caveats

* You need a local user with which to receive bounces so that you have the choice of manually deciding to redirect or delete, as appropriate.
* This does mean this isn't a viable solution for high volume mail servers.

## Prerequisites

* This article is based on using Postfix on Ubuntu 20.04. Other versions of Linux may have a different default Postfix configuration and thus these instructions may need adjusting on non-Debian/Ubuntu systems or even older (or later) versions of Debian/Ubuntu.
* A server with an acceptable public IP (i.e. not on blacklists or having a low reputation with the final destination email server) for sending mail or you need an email relay.
* The server must be able to receive mail on port 25 and to send to same, or receive mail on port 25 and be able to use an email relay to send (many VPS providers do no allow sending mail directly to the internet (specifically port 25 outgoing is often blocked), and those that do often have low reputation IP blocks due to abuse or poorly configured servers being abused unbeknownst the server operator).
* The server must be able to receive traffic on port 80 (HTTP) (or you will have to adjust the instruction for another means than Certbot standalone mode for obtaining SSL certificates).
* The server must have at least 1GB of RAM.
* Some knowledge of Linux system administration (this guide assumes a certain level of working knowledge and ability to troubleshoot errors while attempting to follow the guide).
* Knowledge of regular expression (regexp) syntax and use.

### Packages

* certbot
* mutt
* opendmarc
* opendkim
* postfix
* postfix-policyd-spf-perl
* spamass-milter

#### Install the packages

```bash
sudo apt install -y certbot mutt opendmarc opendkim postfix postfix-policyd-spf-perl spamass-milter
```

## Configuration

### OpenDKIM

1. In the file ``/etc/default/opendkim``, comment (that is make sure the line begins with ``#``) all lines beginning with ``SOCKET=``
2. Add a line as below:

   ```bash
   SOCKET=inet:8896@127.0.0.1
   ```

3. In the file ``/etc/opendkim.conf`` make sure the line containing ``AuthservID`` matches your hostname. If your hostname was ``mail.example.com`` then it should contain ``AuthservID mail.example.com``
4. In the same file, make sure lines contain ``Domain``, ``KeyFile``, and ``Selector`` or commented
5. In the same file, make the line contain ``Mode`` be ``Mode   v``
6. In the same file, set the ``Socket`` line to be ``Socket     inet:8896@127.0.0.1``
7. In the same file, make sure the line with ``TrustAnchorFile`` is commented
8. Add the following lines:

   ```conf
   DNSTimeout 8
   On-BadSignature r
   On-DNSError t
   ```

9. Once you have saved the above files issue:

   ```bash
   systemctl restart opendkim
   ```

### OpenDMARC

1. In the file ``/etc/default/opendmarc``, comment (that is make sure the line begins with ``#``) all lines beginning with ``SOCKET=``
2. Add a line as below:

   ```bash
   SOCKET=inet:8897@127.0.0.1
   ```

3. In the file ``/etc/opendmarc.conf``, make sure the line containing ``AuthservID`` matches your hostname. If your hostname were ``mail.example.com``, then it should contain ``AuthservID mail.example.com``
4. In the same file, set one line to be ``RejectFailures true``
5. In the same file, set the ``Socket`` line to be ``Socket     inet:8897@127.0.0.1``
6. In the same file, set make sure the ``TrustAuthservIDs`` line is ``TrustAuthservIDs HOSTNAME``
7. In the same file, add the following lines:

   ```conf
   SPFIgnoreResults false
   SPFSelfValidate true
   RequiredHeaders true
   ```

8. Once you have saved the above files issue:

   ```bash
   systemctl restart opendmarc
   ```

### Spamass-milter and SpamAssassin

1. In the file ``/etc/default/spamassassin``, change the line with ``CRON=0`` to ``CRON=1``
2. In the file ``/etc/default/spamass-milter`` replace the lines beginning with ``OPTIONS=`` with the following snippet:

   ```bash
   # Default, use the spamass-milter user as the default user, ignore
   # messages from localhost
   OPTIONS="-u spamass-milter -i 127.0.0.1"

   # Reject emails with spamassassin scores > 3.
   #OPTIONS="${OPTIONS} -r 15"
   OPTIONS="${OPTIONS} -r 3"

   # Do not modify Subject:, Content-Type: or body.
   OPTIONS="${OPTIONS} -m"

   # Scan messages up to Postfix max size
   OPTIONS="${OPTIONS} -- -s 10240000"
   ```

3. In the file ``/etc/spamassassin/local.cf``, comment the line containing ``rewrite_header``
4. In the same file, uncomment and set the ``required_score`` line to be ``required_score 3.0``
5. In the same file, comment the line containing ``use_bayes 1`` (bayesian filtering is better used when not using spamassasin as a prequeue milter)
6. In the same file, set the line ``bayes_auto_learn 1`` to ``bayes_auto_learn 0``
7. Once you have saved the above files issue:

   ```bash
   systemctl enable spamassassin spamass-milter
   systemctl restart spamass-milter spamassassin
   ```

### Certbot

1. Assuming your mail server is ``mail.example.com`` and you have port 80 (HTTP) on the server open in your firewall (if any), issue the command:

   ```bash
    sudo certbot certonly --standalone -d mail.example.com
   ```

   and answer the prompts.

### Postfix

**NB**: Includes configuration of postfix-policyd-spf-perl

1. Add the following lines to ``/etc/postfix/master.cf``:

   ```conf
   spfcheck  unix  -       n       n       -       0       spawn
     user=policyd-spf argv=/usr/sbin/postfix-policyd-spf-perl
   ```

2. Edit ``/etc/postfix/main.cf`` to look like the example below (leaving comments that come with the default configuration, if you wish), assuming your mail server is ``mail.example.com``, you are required to use email relay ``relay.example.com``, your final destination email address is in the ``example.net`` domain, you are relaying mail original sent to ``domain1.example.com`` and ``domain2.example.com``, and the final local user for postmaster mail is named ``user1``:

   ```conf
   myorigin = mail.example.com
   myhostname = mail.example.com
   smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
   biff = no
   append_dot_mydomain = no
   readme_directory = no
   compatibility_level = 2
   smtpd_tls_cert_file=/etc/letsencrypt/live/mail.example.com/fullchain.pem
   smtpd_tls_key_file=/etc/letsencrypt/live/mail.example.com/privkey.pem
   smtpd_tls_security_level=may
   smtp_tls_CApath=/etc/ssl/certs
   smtp_tls_security_level=may
   smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
   smtpd_relay_restrictions =
       permit_mynetworks
       reject_unauth_destination
       check_policy_service unix:private/spfcheck
   alias_maps = hash:/etc/aliases
   alias_database = hash:/etc/aliases
   mydestination = $myhostname, localhost.lxd, localhost, mail
   relayhost = [relay.example.com]
   relay_domains = example.net
   mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
   mailbox_size_limit = 0
   recipient_delimiter = +
   inet_interfaces = all
   inet_protocols = all
   virtual_alias_domains = domain1.example.com domain2.example.com
   virtual_alias_maps = regexp:/etc/postfix/virtual
   luser_relay = user1@localhost
   local_recipient_maps =
   milter_protocol = 6
   smtpd_milters = inet:127.0.0.1:8896,inet:127.0.0.1:8897,unix:/spamass/spamass.sock
   milter_default_action = tempfail
   notify_classes = resource, software, 2bounce
   bounce_notice_recipient = postmaster@localhost
   2bounce_notice_recipient = postmaster@localhost
   default_transport = local:$myhostname
   sender_dependent_relayhost_maps = hash:/etc/postfix/sender_relay_transport_map
   spfcheck_time_limit = 3600
   ```

3. Edit ``/etc/aliases`` to contain at least, assuming the final local user for postmaster mail is named ``user1`` and your final destination mail address for email generated on the server is ``mailuser@example.net``:

   ```conf
   postmaster: user1
   root: mailuser@example.net
   ```

4. Issue the command:

   ```bash
   sudo newaliases
   ```

5. Create the file ``/etc/postfix/sender_relay_transport_map`` with the following contents (using the same assumptions as above):

   ```conf
   MAILER-DAEMON@mail.example.com local:mail.example.com
   MAILER-DAEMON@localhost local:mail.example.com
   ```

6. Issue the command:

   ```bash
   sudo postmap hash:/etc/postfix/sender_relay_transport_map
   ```

7. Create the file ``/etc/postfix/virtual`` as appropriate. An example which redirects ``userX`` or ``info`` in any domain in the ``virtual_alias_domains`` above to ``mailuser@example.net``:

   ```conf
   /^user.@.*/ mailuser@example.net
   /^info@.*/ mailuser@example.net
   ```

8. Issue the commands:

   ```bash
   sudo postfix check
   sudo postfix reload
   ```

## Testing and regular checks

* Check your system's logs to verify all is well.
* You should send mail to the users in your aliased domains (e.g. ``domain1.example.com`` or ``domain2.example.com``) to verify valid mail is redirecto to your final destination user (e.g. ``mailuser@example.net``).
* You should also periodically check ``/var/log/mail.log`` and ``/var/log/mail.err`` to verify what happens with spam or otherwise unwanted mail.
* You will also need to regularly login as your local user (e.g. ``user1`` on ``mail.example.com``) and check mail (e.g. using ``mutt``) to deal with any bounced mail (even though bounces should be rare).
