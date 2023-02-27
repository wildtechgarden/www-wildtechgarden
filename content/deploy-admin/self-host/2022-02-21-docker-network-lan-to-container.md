---
slug: docker-network-lan-to-container
aliases:
- /deploy-admin/docker-network-lan-to-container/
- /docs/deploy-admin/self-host/docker-network-lan-to-container/
title: "Docker network: LAN to container"
date: 2022-02-21T11:48:46-05:00
tags:
    - containers
    - hosting
    - linux
    - network
    - self-host
    - sysadmin-devops
summary: "Normally when using Docker one only wants specific unicast ports forwarded, so the standard Docker paradigm of using NAT to forward ports to the container works. However, when using Docker to containerize internal services like Samba (which needs a combination of unicast and broadcast UDP), LLMNR (Windows multicast address resolution), or mDNS a.k.a Bonjour (Apple multicast address resolution) one may find that the standard Docker model is insufficient."
description: "When using Docker with internal services like Samba, LLMNR, or mDNS/Bonjour, one may find that the standard model of using specific unicast ports forwards, is insufficient."
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

Normally when using Docker one only wants specific unicast ports forwarded, so the standard Docker paradigm of using NAT to forward ports to the container works. However, when using Docker to containerize internal services like Samba (which needs a combination of unicast and broadcast UDP), LLMNR (Windows multicast address resolution), or mDNS aka Bonjour (Apple multicast address resolution) one may find that the standard Docker model is insufficient.

If one doesn't need the Docker host, or virtual machines on the Docker host, to access the container then one can simply use [Docker ipvlan L2 networks](https://docs.docker.com/network/ipvlan/#ipvlan-l2-mode-example-usage).

For the exceptions, you might be interested in the configuration below.

## Overview of the configuration

* We create a bridge using SystemD networkd which has a real network interface as a member.
* We create a veth (virtual ethernet) pair of interfaces
  * One interface gets attached to the bridge as a member; this same bridge can be used by virtual machines on the same host to communicate with Docker instances via the second veth interface (details below) as well as the host and LAN (via the real network interface bridge member).
  * The second veth is used as if it were a real interface by the ``docker create`` command to create an ipvlan L2 network. Docker instances that wish to use the bridge attach to the docker network so created.

## Details

### Create the systemd bridge

#### ``br0.netdev``

```ini
[NetDev]
Kind=bridge
Name=br0
```

#### ``br0.network``

```ini
[Match]
Name=br0

[Link]
ARP=yes

[Network]
Gateway=192.168.1.1 # If you have a different gateway, use that address
DHCP=no
DNS=192.168.1.1 # If your DNS server is at a different address, use that address
IPv6AcceptRA=no
LLMNR=yes
IPForward=yes
LLDP=no
EmitLLDP=no

[Address]
Address=192.168.1.XXX/24 # Obviously use the actual IP address for the physical host for 192.168.1.XXX
```

#### ``eth0.network``

``eth0`` should be the actual physical network interface on your Linux host (e.g. ``enp2s0``) and ``MACAddress`` should be set the real MAC address of that interface.

```ini
[Match]
MACAddress=11:22:33:44:55:66
Name=eth0

[Link]
ARP=yes

[Network]
Bridge=br0
LinkLocalAddressing=no
```

### Create the veth pair

We use ``vems0`` as the veth interface that is a member of the bridge and ``vedms0`` as the interface for the Docker Network

#### ``vems0.netdev``

```ini
[NetDev]
Name=vems0
Kind=veth

[Peer]
Name=vedems0
```

#### ``vems0.network``

```ini
[Match]
Name=vems0

[Link]
ARP=yes

[Network]
Bridge=br0
LinkLocalAddressing=no
BindCarrier=br0
```

#### ``vedms0.network``

**NB**: ``vedms0.netdev`` is not needed

```ini
[Match]
Name=vedms0

[Link]
ARP=yes

[Network]
BindCarrier=br0
LinkLocalAddressing=no
```

### Create a Docker ipvlan L2 network

In this example we give the Docker network the 192.168.1.1 to 192.168.1.127 range (192.168.1.0/25). If you have a router giving out DHCP addresses on this network, you should make sure to exclude that range from addresses given to other hosts (e.g. laptops, mobile devices, IoT devices, etc) that are also on the network.

```bash
docker network  create -d ipvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --ip-range=192.168.1.0/25 \
  -o ipvlan_mode=l2 \
  -o parent=vedms0 newnet_name
```

### Configure applicable Docker containers

For this example we assume the use of ``docker-compose``.

#### In ``docker-compose.yml``

Obviously this omits the non-network configuration that you would need.

```yaml
networks:
  newnet_name:
    external: true

services:
  someservice:
    networks:
      newnet_name:
        ipv4_address: 192.168.1.XXX # Where you use the LAN address to assign to the container
```

#### Example when using services on the LAN and internal Docker networks

Obviously this omits the non-network configuration that you would need.

```yaml
networks:
  newnet_name:
    external: true
  stacknet:
    driver: bridge

services:
  someservice:
    networks:
      newnet_name:
        ipv4_address: 192.168.1.XXX # Where you use the LAN address to assign to the container
      stacknet:
  supportservice:
    networks:
      stacknet:
```

## Bring up the services

E.g. ``docker-compose up --build -d``

Now you should be able to access someservice via it's ipv4 address on any TCP/UDP port or other IP-based protocol.
