---
slug: pi-unbound-the-gift-of-dot
aliases:
- /deploy-admin/pi-unbound-the-gift-of-dot/
- /docs/deploy-admin/sysadmin-devops/pi-unbound-the-gift-of-dot/
title: "Pi Unbound: The gift of DoT"
date: 2021-12-20T14:31:45-05:00
publishDate: 2021-12-20T14:31:45-05:00
tags:
    - sbc
    - debian
    - hosting
    - infrastructure
    - linux
    - raspberry-pi
    - router
    - self-host
    - security
    - system-administration
description: "Using Unbound DNS resolver on a Raspberry Pi to enable DNS over TLS and DNSSEC for all your systems (including Windows and IoT devices)"
summary: "Keeping your DNS queries from your local network to public DNS servers private in transit by using DNS over TLS on a Raspberry Pi is ridiculously easy."
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Overview

Keeping your DNS queries from your local network to public DNS servers private while in transit by using DNS over TLS on a Raspberry Pi is ridiculously easy.

For bonus points this guide also shows how to use the same DNS server to provide you local network with hostnames to local IP addresses (local DNS), as well as how to successfully use this on your post-modern linux system that uses systemd resolved with DoT enabled.

Oh, and you get DNSSEC for free with this!

### What is DNS over TLS (DoT) and why should you want it?

>DNS over TLS (DoT) is a network security protocol for encrypting and wrapping Domain Name System (DNS) queries and answers via the Transport Layer Security (TLS) protocol. The goal of the method is to increase user privacy and security by preventing eavesdropping and manipulation of DNS data via man-in-the-middle attacks.
> — From [DNS_over_TLS](https://en.wikipedia.org/wiki/DNS_over_TLS) on [Wikipedia](https://en.wikipedia.org/wiki/Main_Page)

### What is DNSSEC and why should you want it?

>DNSSEC is an end-to-end security layer designed to ensure secure communication throughout the domain name system. DNSSEC provides a layer of authentication so that an end user has certain assurances that they are reaching the actual website.
> — From [DNSSEC: Securing the domain name system](https://www.cira.ca/dnssec-securing-domain-name-system) on [CIRA's Website](https://www.cira.ca/) (CIRA is the Canadian Internet Registration Authority).

### Limitations

These technologies do not prevent the provider of the DNS service you are using from seeing your IP address and/or logging your queries; the job of DoT (and an alternative technology called DNS over HTTP or 'DoH') is keep the traffic private while in transit between you and the provider. The job of DNSSEC is to authenticate that you are connecting to the actual site you think you are (that is, it is a signing mechanism not an encryption mechanism).

In my case, as a Canadian I have the availability of the [Canadian Shield](https://www.cira.ca/cybersecurity-services/canadian-shield) service by [CIRA](https://www.cira.ca/), which I quite frankly find more trustworthy than random servers offering privacy services, especially ones that do so for free. While there are enough folks who would be willing and able to offer such services for free on a small scale out of an honest belief it is a good thing, in the absence of trustworthy audits or verification of the service, or some credible business model for offering it at scale (and especially then I'd want a trustworthy audit) I would be less convinced of the value of using DoT/DoH instead of the DNS servers offered by my ISP (which do support DNSSEC). That said, if you don't have the option (or trust) of CIRA, a quick search will reveal a number of DNS providers offering DNSSEC and DoT servers. I leave it to you to decide who you are willing to trust with your DNS data.

## Setup

1. [Configure your Raspberry Pi as a server](../self-host/2020-09-08-raspberry-pi-os-for-a-server.md) using Pi OS based on Bullseye or Ubuntu Server 21.04 (Pi 2 or higher only) or similarly capable Linux system.
2. Add the Unbound DNS resolver and the Unbound 'host' tool

   ```bash
   sudo apt-get install -y unbound unbound-host
   ```

3. Add a file such as ``/etc/unbound/unbound.conf.d/interfaces.conf``:

   ```conf
   server:
       interface: 192.168.1.38
       interface: 127.0.0.1
   ```

   This allows your Pi (assuming it's IP address is 192.168.1.38) to use systemd-resolved for name resolution, defaulting to the Unbound server, with a fallback as defined in resolved.conf (below). If you do not bind to particular interfaces then you cannot also have system-resolved running as ``127.0.0.53:53`` will already in use when Unbound tries to bind to all available addresses.

4. Add a file such as ``/etc/unbound.conf.d/forwarding-servers.conf``:

   ```conf
   forward-zone:
       name: "."
       forward-host: protected.canadianshield.cira.ca
       forward-addr: 149.112.121.20@853
       forward-addr: 149.112.122.20@853
       forward-ssl-upstream: yes
   ```

   In this example we use the [CIRA Canadian Shield](https://www.cira.ca/cybersecurity-services/canadian-shield) as our 'upstream' DNS servers. You will likely wish to adjust to servers applicable to your situation.

5. And another file: ``/etc/unbound.conf.d/disable-remote-control.conf``:

   ```conf
   remote-control:
       no
   ```

   This should be the default, but better safe than sorry.
6. For local hostnames you can add ``/etc/unbound/unbound.conf.d/lan-zone.conf`` as adjusted for your network. (For details see [the unbound.conf man page](https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html))

   ```conf
   server:
       domain-insecure: internal.example.net
       local-zone: "internal.example.net" transparent
       local-data: "piunbound.internal.example.net. 3600 IN A 192.168.1.38"
       local-data: "yourworkstation.internal.example.net. 3600 IN A 192.168.1.60"
   ```

   and for 'reverse DNS' (number to name instead of name to number):

   ```conf
   server:
       local-zone: "1.168.192.in-addr.arpa." static
       local-data: "38.1.168.192.in-addr.arpa. 3600 IN PTR piunbound.internal.example.net."
       local-data: "60.1.168.192.in-addr.arpa. 3600 IN PTR yourworkstation.internal.example.net."
   ```

## Use

### Configure your router

This varies from router to router, but some [general instructions](https://www.cira.ca/cybersecurity-services/canadian-shield/configure) [CIRA](https://www.cira.ca/) provides (in the 'Home router/gateway' section) can be used, except that instead of using the Canadian Shield DNS addresses you use only your Unbound Pi IP address. For those who are alert, you will realize the CIRA addresses (or equivalent if you are not using CIRA's servers, above) are already used in the Unbound configuration and therefore will by used by systems that use your Pi. It will simply be through the Pi instead of through the router (with the addition of using DNS over TLS and DNSSEC).

### Configure Windows, smartphones and other devices

The best way to configure most devices (without exotic setups) to use your Pi is to configure your router. If you router is configured correctly it will give out the Pi's DNS via DHCP. For a device such as a Windows laptop this has the advantage that when you are not on your local network (e.g. at a café), then DNS will still resolve (albeit without the DoT and likely without DNSSEC, unless you use a VPN that provides these). If configuring your router is not an option for you, then you need to configure each device.

Since configuring each device is different for each type of device, doing so is out of scope for this article.

### Configure Linux (when using SystemD ResolveD)

This is a special case and, for a Linux laptop, has the benefit that you can configure it to use DoT and DNSSEC even when out and about (i.e. not using the Pi).

#### Option 1: DNS via SystemD; network not handled by SystemD

The first configuration we cover is for the case where the network setup is managed outside SystemD (such as the typical use of NetworkManager by most distributions used on a laptop). You can also use this config on the Unbound Pi.

In this example we use the [CIRA Canadian Shield](https://www.cira.ca/cybersecurity-services/canadian-shield) as our 'upstream' DNS servers. You will likely wish to adjust to servers applicable to your situation.

1. Edit ``/etc/systemd/resolved.conf`` with contents such as (assuming your Pi's IP address is 192.168.1.38) and adjusted for your network:

   ```conf
   [Resolve]
   DNS=192.168.1.38
   FallbackDNS=149.112.121.20#protected.canadianshield.cira.ca 149.112.122.20#protected.canadianshield.cira.ca
   Domains=internal.example.net
   DNSSECNegativeTrustAnchors=internal.example.net
   DNSOverTLS=opportunistic
   ```

2. Enable systemd-resolved:

   ```bash
   sudo systemctl enable --now systemd-resolved
   ```

3. Use systemd to provide your `resolv.conf` file (used by some programs to configure name resolution).

   ```bash
   sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
   ```

#### Option 2: DNS and Network via SystemD

In this example we use the [CIRA Canadian Shield](https://www.cira.ca/cybersecurity-services/canadian-shield) as our 'upstream' DNS servers. You will likely wish to adjust to servers applicable to your situation.

1. Configure the network (this assumes you have already disabled non-systemD network; doing so is out of scope for this article). In this example we edit ``/etc/systemd/network/enp3s0.conf`` (where ``enp3s0`` is the network device we are configuring). For WiFi and/or any number of complex things you can do with you network, you will need to refer to the SystemD documentation and/or other guides.

   ```conf
   [Match]
   MACAddress=xx:xx:xx:00:00:00 ; Obviously use your actual MAC address

   [Network]
   Gateway=192.168.1.1 ; Adjust according to your network; usually the address of your router
   LLMNR=yes
   DNSOverTLS=opportunistic
   DNSSEC=yes
   DNSSECNegativeTrustAnchors=internal.example.net
   LLDP=no
   EmitLLDP=no
   DNS=149.112.121.20#protected.canadianshield.cira.ca 149.112.122.20#protected.canadianshield.cira.ca
   DNS=192.168.1.38 ; Adjust to address of your Pi
   Domains=internal.example.net ~.
   ```

2. ``sudo networkctl reload``
3. Edit ``/etc/systemd/resolved.conf`` with contents such as (adjusted for your network):

   ```conf
   [Resolve]
   FallbackDNS=149.112.121.20#protected.canadianshield.cira.ca 149.112.122.20#protected.canadianshield.cira.ca
   DNSOverTLS=opportunistic
   ```

4. Enable systemd-resolved:

   ```bash
   sudo systemctl enable --now systemd-resolved
   ```

5. Use systemd to provide your ``resolv.conf`` file (used by some programs to configure name resolution).

   ```bash
   sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
   ```
