---
slug: configure-an-ovh-vps-with-centos-7
aliases:
    - /2019/10/04/configure-an-ovh-vps-with-centos-7/
    - /post/configure-an-ovh-vps-with-centos-7/
    - /deploy-admin/configure-an-ovh-vps-with-centos-7/
    - /configure-an-ovh-vps-with-centos-7/
    - /docs/sysadmin-devops/self-host/configure-an-ovh-vps-with-centos-7/
    - /sysadmin-devops/self-host/configure-an-ovh-vps-with-centos-7/
    - /docs/deploy-admin/self-host/configure-an-ovh-vps-with-centos-7/
author: Daniel F. Dickinson
date: '2019-10-05T03:23:00+00:00'
publishDate: '2019-10-05T03:23:00+00:00'
summary: CentOS 7 has been a stable and reliable choice for VPS servers. This guide shows how to install it on an OVH VPS (Virtual Private Server)
description: CentOS 7 has been a stable and reliable choice for VPS servers. This guide shows how to install it on an OVH VPS (Virtual Private Server)
tags:
- archived
- centos
- cloud
- linux
- self-host
- sysadmin-devops
- virtualization
title: "ARCHIVED: An OVH VPS with CentOS 7"
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## Overview

A guide to configuring an OVH VPS (Virtual Private Server) with CentOS 7

## Preliminaries

1. Configure your DNS with a hostname pointing to the IP that has been assigned to your instance. As doing so depends on who your DNS provider is, documenting this is beyond the scope of this document.
2. Locally create a SSH keypair (or keypairs) if you don’t already have one. See one of the many guides on the internet if you need more information, for example:
   * [GitHub’s Guide for SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
   * [Scaleway’s Guide for SSH Key Generation](https://www.scaleway.com/en/docs/console/my-project/how-to/create-ssh-key/)
   * [OVH’s Guide for SSH Key Generation](https://docs.ovh.com/gb/en/public-cloud/public-cloud-first-steps/#step-1-creating-ssh-keys)
3. In your OVH Web Control Panel (``https://xx.ovh.com/manager``, where xx is the ISO two letter country code for your OVH billing/admin), in your account information (the menu that appears when you click on your name on the top-right, select ‘My Account’), select ‘My SSH Keys’, then ‘Add an SSH key’ - for a more complete guide see ~~[OVH’s guide configuring SSH keys]\(``https://www.ovh.com/ca/en/configuring_additional_ssh_keys``)~~. It is recommended to use a separate SSH key here rather than the key you will use during regular operation.
4. Change your server’s hostname for OVH purposes:
   1. Select Cloud|Servers|\<your new server>
   2. Under the ‘Configuration’ section click on the circle with ... to right of the current hostname (in the row titled ‘Name’)
   3. Click on ‘Modify’
   4. Enter your new hostname (the DNS you configured above).
   5. In ‘IP’ section for the row ‘Reverse DNS’ select ‘…’ and configure your IP(s) to point to your hostname (only one hostname per address family (ipv4/ipv6).
   6. Reinstall your VPS with CentOS 7 – you will be prompted for the SSH keys to include in the image; they will be used to allow public key root login; also deselect ‘email me my authentication/credentials’. It is recommended to use a separate SSH for this initial deployment than for regular use.

## After OS install completes

1. ssh root@\<your-vps-ip-or-hostname>
2. Change root password (execute passwd root)
3. Edit /etc/cloud/cloud.cfg
   * Edit ``hostname: <default-hostname>`` to be your desired hostname.
   * Set ``ssh_pwauth: 0`` (after setting up public/private keypair, below).
4. Set hostname for instance: hostnamectl set-hostname new-hostname
5. Make sure /etc/hosts has your IP (v4 and/or v6) to hostname mapping

   ```conf
   127.0.0.1 localhost
   xxx.xxx.xxx.xxxx exhost.example.com exhost

   # If you wish to support ipv6
   ::1 localhost
   abcd:0124:ef56:789a::aaaa exhost.example.com exhost
   ```

6. Add a regular user who is a member of ‘adm’, ‘systemd-journal’, ‘wheel’ and allow only public/private key login for that user.
   1. ``adduser -U -G adm,systemd-journal,wheel username``
   2. Set the password for that user: ``passwd username``
   3. Switch to that user: ``su - username``
   4. ``mkdir ~/.ssh``
   5. From your local host copy your regular operating SSH public key to the user you just created: ``scp ssh-key.pub username@your-host.example.com:.ssh/authorized_keys``
   6. Back on the VPS as the regular user you created: ``chmod 600 ~/.ssh/authorized_keys``
   7. From your local host login to the VPS using the private key associated with the public key you just copied to the VPS: ``ssh -i ssh-key username@your-host.example.com``. You should get to a shell prompt without having to enter a password for the user (you may have to enter the SSH key’s password, however). If not troubleshoot and fix what is wrong before going on to the next step.
   8. Disable password authentication by editing /etc/ssh/sshd_config so that ``PasswordAuthentication`` no is set and *not* PasswordAuthentication yes. Use the user you created to do this via sudoedit. This verifies that you can obtain root through this user.
7. Disable root logins via SSH: Edit /etc/ssh/sshd_config to set ``PermitRootLogin no``.
8. To avoid log spam from failed SSH brute force attempts change the SSH port (**NB** This isn’t a real security measure, it just avoids having your journal filled with ‘script kiddy’ level failures — you are using SSH public keys, not passwords of course).
   1. Tell SELinux to allow SSH on your new port (we use 28322 for this example: 10000-65535 are mostly safe although there may be ports already in use; use ss -lut to check your ports in use) ``semanage port -a -t ssh_port_t -p tcp 28332``
   2. Update SSH config to use the new port by changing the Port 22 directive in /etc/ssh/sshd_config to Port 28332
   3. Configure firewall logging by running ``firewall-cmd --set-log-denied=unicast``
   4. Allow the new port through your firewall:

      ```sh
      firewall-cmd --permanent --new-service=altssh firewall-cmd --permanent --service=altssh --add-port=28332/tcp firewall-cmd --permanent --add-service altssh firewall-cmd --complete-reload
      ```

   5. Restart SSH (systemctl restart sshd)
   6. Login again (a second session) using the new port (e.g. ssh -p 28332 your-user@your-dns-address-or-ip- address).
9. Permanently enable firewall in VPS: ``systemctl enable --now firewalld``.
10. Exit all SSH sessions except the last one you started.
11. Enable OVH Firewall (see OVH docs for this; this reduces the load on your VPS/VM by letting OVH handle the majority of firewall traffic): See [OVH firewall network (anti-DDOS)](https://docs.ovh.com/gb/en/dedicated/firewall-network/#objective)
12. Install useful admin tools
    * byobu (pre-installed on Ubuntu / Docker on Ubuntu images)
      * ``byobu-config`` (as each user for which you wish to use byobu
      * ``byobu-enable`` (for each user for which you wish to byobu to launch on logon; it is not recommended to do this for root as there is a potential for for getting locked out of the root account in certain error scenarios).
      * ``touch ~/.byobu/.always-select`` (if you want to be prompted to resume an old session (if present) and otherwise start a new session when byobu launches.
    * logwatch
    * psmisc
    * rsync
    * mutt
13. Enable SELinux if it’s not enabled
    * Edit /etc/sysconfig/selinux so that it has the line SELINUX=enforcing and *not* SELINUX=permissive or SELINUX=disabled.
14. Edit /etc/sysconfig/network-scripts/ifcfg-eth0 (only needed if you wish to support ipv6).

    ```sh
    BOOTPROTO=dhcp
    DEVICE=eth0
    HWADDR=\<macaddr>
    ONBOOT=yes
    TYPE=Ethernet
    USERCTL=no
    IPV6INIT=yes
    IPV6_AUTOCONF=no
    IPV6_DEFROUTE=yes
    IPV6_FAILURE_FATAL=no
    IPV6ADDR=\<ipv6-addr/cidr>
    IPV6_DEFAULTGW=\<ipv6-gateway-addr>
    ZONE=\<firewall-zone>
    ```

15. Enable ipv6 (if wanted) by adding the following to /etc/ sysconfig/network. (Obviously you only do this if you’re supporting ipv6): NETWORKING_IPV6=yes
16. Add /etc/cloud/cloud.cfg.d/00_disable_cloud_init_networking.cfg. Only if you’ve done the manual network configuration above.

    ```yaml
    network:
    config: disabled
    ```

17. Allow SLA monitoring from OVH
    1. In your control panel find the SLA address ranges to allow, and issue a command similar to the following for each range:

       ```sh
       firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 1 -s \<range> -j ACCEPT
       ```

    2. Then ``firewall-cmd --complete-reload``
18. Install epel-release to get EPEL repository (``yum install epel-release``)
19. Install yum-cron
    * Edit /etc/yum/yum-cron.conf and /etc/yum/yum-cron- hourly.conf to suit your preferences.
