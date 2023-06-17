---
slug: intel-nuc-like-server
aliases:
    - /docs/sbc-intel-nuc-like-server/
    - /sysadmin-devops/self-host/intel-nuc-like-server/
    - /deploy-admin/intel-nuc-like-server/
    - /docs/deploy-admin/self-host/intel-nuc-like-server/
title: Intel NUC(-like) as a server
author: Daniel F. Dickinson
date: 2021-05-18T03:56:34-04:00
publishDate: 2021-05-18T03:56:34-04:00
tags:
- linux
- self-host
- sysadmin-devops
summary: "The Intel NUC (and boards based on the same SoC) are quite powerful for their price point, and use less electricity than even a mini tower."
description: "The Intel NUC (and boards based on the same SoC) are quite powerful for their price point, and use less electricity than even a mini tower."
---

{{< details-toc >}}

## Preface

The Intel NUC (and boards based on the same SoC) are quite powerful for their price point, and use less electricity than even a mini tower. They are more expensive and power hungry than a Raspberry Pi, but are generally more powerful, and have the advantage of being x86_64 chipsets, which is a software compatibility bonus for some applications.  This article discusses using one such with Ubuntu Server 20.04 LTS (Focal Fossa) as the basis for a server for a webapp (Nextcloud, to be discussed in another article).

The device used in this article has a dual core 1.6 GHz CPU, with 2 GB of RAM and is about the size two paperback novels stacked one on top of the other. In addition it has USB 3.0 ports, to which we will attach external storage. However it already has internal storage so the external storage will be used strictly for data storage. It is fanless, which is a nice bonus for keeping noise down.

For this guide you will need two USB sticks.  The USB stick for Ubuntu Server 20.04 needs to be at least 1.2 GB; the second stick doesn't even need to be 512 MB (but can be as large as you have).

## Installing Ubuntu Server using auto install

### Create the installation media

Since the author has decided to use Ubuntu Server 20.04 this is quite easy.

1. Download the install image from <https://releases.ubuntu.com/20.04/>
2. Create a bootable USB stick
   1. [From Ubuntu](https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu)
   2. [From  Windows](https://ubuntu.com/tutorials/create-a-usb-stick-on-windows)
   3. [From macOS](https://ubuntu.com/tutorials/create-a-usb-stick-on-macos)

### Create a USB stick with auto-install configuration

1. For this you need a second USB stick. Using the disk formatting tools in your operating system, format the entire drive as FAT32 (Ubuntu 21.04 Desktop just calls this FAT in the format options popup).
2. Create a file on the second stick called ``meta-data`` containing data like:

   ```yaml
   instance-id: ubuntu-server-01
   local-hostname: ubuntu-server
   ```

   where``ubuntu-server`` can be your preferred hostname (following the rules for allowed DNS hostnames).
3. Create another file on the second stick, this one called ``user-data``, which is as an Ubuntu Auto-Install YAML file such as:

   ```yaml
   #cloud-config
   autoinstall:
   version: 1
   locale: en_CA.UTF-8
   apt:
       geoip: true
       preserve_sources_list: false
       primary:
       - arches: [amd64, i386]
           uri: http://ca.archive.ubuntu.com/ubuntu
       - arches: [default]
           uri: http://ports.ubuntu.com/ubuntu-ports
   interactive-sections:
       - locale
       - storage
   keyboard: { layout: us, toggle: null, variant: "" }
   refresh-installer:
       update: yes
   network:
       ethernets:
       enp3s0:
           dhcp4: true
           dhcp6: true
       version: 2
   packages:
       - byobu
       - etckeeper
       - fail2ban
       - iftop
       - iotop
       - lsb-invalid-mta
       - lvm2
       - molly-guard
       - restic
       - unattended-upgrades
       - ufw
       - whois
   ssh:
       install-server: yes
       allow-pw: no
       authorized-keys: []
   user-data:
      byobu_by_default: system
       disable_root: true
       preserve_hostname: false
       manage_etc_hosts: true
       hostname: ubuntu-server
       fqdn: ubuntu-server.example.com
       ntp:
         enabled: true
       ssh_pwauth: false
       locale: en_CA.UTF-8
       users:
       - name: anadmin
           groups:
           - adm
           - staff
           - sudo
           homedir: /local-home/anadmin
           hash_passwd: $6$rounds=4096$cvfk94OlGYkBwGLZ$./D0dD7NXqAwCV6YRshC2xDSpWDtpiOP0EdeRO5J69emARWEvklfIFdqB4X2Sw0tdQG2BAUDq3F0N2mT5CLhm1
           lock_passwd: false
           shell: /bin/bash
           ssh_authorized_keys:
             - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6Xbk14Y8IZHmMcqOuMvzjIjqpvMvgDjCE5IDQHDYjYV3nJ98unluCW8xO9KcGUAbYE718Pp0K7r0m3MrXpeC9+P6Sltw+1zgGKYhHJhBaxn2vmZUSxH88ZhN0PTKSeGbxuXHMIE53Pi7eULDk7IC83gQt4cGYjlmqt35+sRdiiPhf3VAsJMwXVLPtdWWM30f6KVaAAYg4yQX5C5SADPOBm2JoCTrIb6bchmp9TJ09RcyX0K2eq0anc0UMV8hVkpO2sYEYjrZdHISafZy2tfcloVdNgqBxzULTdpnhQ0kvzhCX+QE6mLwSvZZz6kxfg5wX0RjH9UzDd4yD79Q3jCNChWyRBZwG+yLOjbY+8BMX+jWJ0EnX+aIULcAa9dB8GtzU0uTLz692aPzPIxRQaAkAJ1UmM1PxdvD/6X2Kj0qVMQ+NLBtoL2KXTWIGbTtwyFzjcOP+1ssK6nFiDpKwXBcgERlJY0QxJc6Hbg8BDMxgcBCdzkjnQ4tZ3ggFNDgJ3Kc= test@example.com
       package_update: true
       package_upgrade: true
       package_reboot_if_required: true
       timezone: America/Toronto
       write_files:
       - path: /etc/byobu/autolaunch
       - path: /etc/ssh/sshd_config.d/pubkey_only.conf
           content: |
           PasswordAuthentication no
           PubkeyAuthentication yes
       - path: /etc/apt/apt.conf.d/50unattended-upgrades
           content: |
             Ly8gQXV0b21hdGljYWxseSB1cGdyYWRlIHBhY2thZ2VzIGZyb20gdGhlc2UgKG9yaWdpbjphcmNo
             aXZlKSBwYWlycwovLwovLyBOb3RlIHRoYXQgaW4gVWJ1bnR1IHNlY3VyaXR5IHVwZGF0ZXMgbWF5
             IHB1bGwgaW4gbmV3IGRlcGVuZGVuY2llcwovLyBmcm9tIG5vbi1zZWN1cml0eSBzb3VyY2VzIChl
             LmcuIGNocm9taXVtKS4gQnkgYWxsb3dpbmcgdGhlIHJlbGVhc2UKLy8gcG9ja2V0IHRoZXNlIGdl
             dCBhdXRvbWF0aWNhbGx5IHB1bGxlZCBpbi4KVW5hdHRlbmRlZC1VcGdyYWRlOjpBbGxvd2VkLU9y
             aWdpbnMgewoJIiR7ZGlzdHJvX2lkfToke2Rpc3Ryb19jb2RlbmFtZX0iOwoJIiR7ZGlzdHJvX2lk
             fToke2Rpc3Ryb19jb2RlbmFtZX0tc2VjdXJpdHkiOwoJLy8gRXh0ZW5kZWQgU2VjdXJpdHkgTWFp
             bnRlbmFuY2U7IGRvZXNuJ3QgbmVjZXNzYXJpbHkgZXhpc3QgZm9yCgkvLyBldmVyeSByZWxlYXNl
             IGFuZCB0aGlzIHN5c3RlbSBtYXkgbm90IGhhdmUgaXQgaW5zdGFsbGVkLCBidXQgaWYKCS8vIGF2
             YWlsYWJsZSwgdGhlIHBvbGljeSBmb3IgdXBkYXRlcyBpcyBzdWNoIHRoYXQgdW5hdHRlbmRlZC11
             cGdyYWRlcwoJLy8gc2hvdWxkIGFsc28gaW5zdGFsbCBmcm9tIGhlcmUgYnkgZGVmYXVsdC4KCSIk
             e2Rpc3Ryb19pZH1FU01BcHBzOiR7ZGlzdHJvX2NvZGVuYW1lfS1hcHBzLXNlY3VyaXR5IjsKCSIk
             e2Rpc3Ryb19pZH1FU006JHtkaXN0cm9fY29kZW5hbWV9LWluZnJhLXNlY3VyaXR5IjsKCSIke2Rp
             c3Ryb19pZH06JHtkaXN0cm9fY29kZW5hbWV9LXVwZGF0ZXMiOwovLwkiJHtkaXN0cm9faWR9OiR7
             ZGlzdHJvX2NvZGVuYW1lfS1wcm9wb3NlZCI7Ci8vCSIke2Rpc3Ryb19pZH06JHtkaXN0cm9fY29k
             ZW5hbWV9LWJhY2twb3J0cyI7Cn07CgovLyBQeXRob24gcmVndWxhciBleHByZXNzaW9ucywgbWF0
             Y2hpbmcgcGFja2FnZXMgdG8gZXhjbHVkZSBmcm9tIHVwZ3JhZGluZwpVbmF0dGVuZGVkLVVwZ3Jh
             ZGU6OlBhY2thZ2UtQmxhY2tsaXN0IHsKICAgIC8vIFRoZSBmb2xsb3dpbmcgbWF0Y2hlcyBhbGwg
             cGFja2FnZXMgc3RhcnRpbmcgd2l0aCBsaW51eC0KLy8gICJsaW51eC0iOwoKICAgIC8vIFVzZSAk
             IHRvIGV4cGxpY2l0ZWx5IGRlZmluZSB0aGUgZW5kIG9mIGEgcGFja2FnZSBuYW1lLiBXaXRob3V0
             CiAgICAvLyB0aGUgJCwgImxpYmM2IiB3b3VsZCBtYXRjaCBhbGwgb2YgdGhlbS4KLy8gICJsaWJj
             NiQiOwovLyAgImxpYmM2LWRldiQiOwovLyAgImxpYmM2LWk2ODYkIjsKCiAgICAvLyBTcGVjaWFs
             IGNoYXJhY3RlcnMgbmVlZCBlc2NhcGluZwovLyAgImxpYnN0ZGNcK1wrNiQiOwoKICAgIC8vIFRo
             ZSBmb2xsb3dpbmcgbWF0Y2hlcyBwYWNrYWdlcyBsaWtlIHhlbi1zeXN0ZW0tYW1kNjQsIHhlbi11
             dGlscy00LjEsCiAgICAvLyB4ZW5zdG9yZS11dGlscyBhbmQgbGlieGVuc3RvcmUzLjAKLy8gICIo
             bGliKT94ZW4oc3RvcmUpPyI7CgogICAgLy8gRm9yIG1vcmUgaW5mb3JtYXRpb24gYWJvdXQgUHl0
             aG9uIHJlZ3VsYXIgZXhwcmVzc2lvbnMsIHNlZQogICAgLy8gaHR0cHM6Ly9kb2NzLnB5dGhvbi5v
             cmcvMy9ob3d0by9yZWdleC5odG1sCn07CgovLyBUaGlzIG9wdGlvbiBjb250cm9scyB3aGV0aGVy
             IHRoZSBkZXZlbG9wbWVudCByZWxlYXNlIG9mIFVidW50dSB3aWxsIGJlCi8vIHVwZ3JhZGVkIGF1
             dG9tYXRpY2FsbHkuIFZhbGlkIHZhbHVlcyBhcmUgInRydWUiLCAiZmFsc2UiLCBhbmQgImF1dG8i
             LgpVbmF0dGVuZGVkLVVwZ3JhZGU6OkRldlJlbGVhc2UgImF1dG8iOwoKLy8gVGhpcyBvcHRpb24g
             YWxsb3dzIHlvdSB0byBjb250cm9sIGlmIG9uIGEgdW5jbGVhbiBkcGtnIGV4aXQKLy8gdW5hdHRl
             bmRlZC11cGdyYWRlcyB3aWxsIGF1dG9tYXRpY2FsbHkgcnVuIAovLyAgIGRwa2cgLS1mb3JjZS1j
             b25mb2xkIC0tY29uZmlndXJlIC1hCi8vIFRoZSBkZWZhdWx0IGlzIHRydWUsIHRvIGVuc3VyZSB1
             cGRhdGVzIGtlZXAgZ2V0dGluZyBpbnN0YWxsZWQKLy9VbmF0dGVuZGVkLVVwZ3JhZGU6OkF1dG9G
             aXhJbnRlcnJ1cHRlZERwa2cgInRydWUiOwoKLy8gU3BsaXQgdGhlIHVwZ3JhZGUgaW50byB0aGUg
             c21hbGxlc3QgcG9zc2libGUgY2h1bmtzIHNvIHRoYXQKLy8gdGhleSBjYW4gYmUgaW50ZXJydXB0
             ZWQgd2l0aCBTSUdURVJNLiBUaGlzIG1ha2VzIHRoZSB1cGdyYWRlCi8vIGEgYml0IHNsb3dlciBi
             dXQgaXQgaGFzIHRoZSBiZW5lZml0IHRoYXQgc2h1dGRvd24gd2hpbGUgYSB1cGdyYWRlCi8vIGlz
             IHJ1bm5pbmcgaXMgcG9zc2libGUgKHdpdGggYSBzbWFsbCBkZWxheSkKLy9VbmF0dGVuZGVkLVVw
             Z3JhZGU6Ok1pbmltYWxTdGVwcyAidHJ1ZSI7CgovLyBJbnN0YWxsIGFsbCB1cGRhdGVzIHdoZW4g
             dGhlIG1hY2hpbmUgaXMgc2h1dHRpbmcgZG93bgovLyBpbnN0ZWFkIG9mIGRvaW5nIGl0IGluIHRo
             ZSBiYWNrZ3JvdW5kIHdoaWxlIHRoZSBtYWNoaW5lIGlzIHJ1bm5pbmcuCi8vIFRoaXMgd2lsbCAo
             b2J2aW91c2x5KSBtYWtlIHNodXRkb3duIHNsb3dlci4KLy8gVW5hdHRlbmRlZC11cGdyYWRlcyBp
             bmNyZWFzZXMgbG9naW5kJ3MgSW5oaWJpdERlbGF5TWF4U2VjIHRvIDMwcy4KLy8gVGhpcyBhbGxv
             d3MgbW9yZSB0aW1lIGZvciB1bmF0dGVuZGVkLXVwZ3JhZGVzIHRvIHNodXQgZG93biBncmFjZWZ1
             bGx5Ci8vIG9yIGV2ZW4gaW5zdGFsbCBhIGZldyBwYWNrYWdlcyBpbiBJbnN0YWxsT25TaHV0ZG93
             biBtb2RlLCBidXQgaXMgc3RpbGwgYQovLyBiaWcgc3RlcCBiYWNrIGZyb20gdGhlIDMwIG1pbnV0
             ZXMgYWxsb3dlZCBmb3IgSW5zdGFsbE9uU2h1dGRvd24gcHJldmlvdXNseS4KLy8gVXNlcnMgZW5h
             YmxpbmcgSW5zdGFsbE9uU2h1dGRvd24gbW9kZSBhcmUgYWR2aXNlZCB0byBpbmNyZWFzZQovLyBJ
             bmhpYml0RGVsYXlNYXhTZWMgZXZlbiBmdXJ0aGVyLCBwb3NzaWJseSB0byAzMCBtaW51dGVzLgov
             L1VuYXR0ZW5kZWQtVXBncmFkZTo6SW5zdGFsbE9uU2h1dGRvd24gImZhbHNlIjsKCi8vIFNlbmQg
             ZW1haWwgdG8gdGhpcyBhZGRyZXNzIGZvciBwcm9ibGVtcyBvciBwYWNrYWdlcyB1cGdyYWRlcwov
             LyBJZiBlbXB0eSBvciB1bnNldCB0aGVuIG5vIGVtYWlsIGlzIHNlbnQsIG1ha2Ugc3VyZSB0aGF0
             IHlvdQovLyBoYXZlIGEgd29ya2luZyBtYWlsIHNldHVwIG9uIHlvdXIgc3lzdGVtLiBBIHBhY2th
             Z2UgdGhhdCBwcm92aWRlcwovLyAnbWFpbHgnIG11c3QgYmUgaW5zdGFsbGVkLiBFLmcuICJ1c2Vy
             QGV4YW1wbGUuY29tIgpVbmF0dGVuZGVkLVVwZ3JhZGU6Ok1haWwgIiI7CgovLyBTZXQgdGhpcyB2
             YWx1ZSB0byBvbmUgb2Y6Ci8vICAgICJhbHdheXMiLCAib25seS1vbi1lcnJvciIgb3IgIm9uLWNo
             YW5nZSIKLy8gSWYgdGhpcyBpcyBub3Qgc2V0LCB0aGVuIGFueSBsZWdhY3kgTWFpbE9ubHlPbkVy
             cm9yIChib29sZWFuKSB2YWx1ZQovLyBpcyB1c2VkIHRvIGNob3NlIGJldHdlZW4gIm9ubHktb24t
             ZXJyb3IiIGFuZCAib24tY2hhbmdlIgovLyBVbmF0dGVuZGVkLVVwZ3JhZGU6Ok1haWxSZXBvcnQg
             Im9ubHktb24tZXJyb3IiOwoKLy8gUmVtb3ZlIHVudXNlZCBhdXRvbWF0aWNhbGx5IGluc3RhbGxl
             ZCBrZXJuZWwtcmVsYXRlZCBwYWNrYWdlcwovLyAoa2VybmVsIGltYWdlcywga2VybmVsIGhlYWRl
             cnMgYW5kIGtlcm5lbCB2ZXJzaW9uIGxvY2tlZCB0b29scykuCi8vVW5hdHRlbmRlZC1VcGdyYWRl
             OjpSZW1vdmUtVW51c2VkLUtlcm5lbC1QYWNrYWdlcyAidHJ1ZSI7CgovLyBEbyBhdXRvbWF0aWMg
             cmVtb3ZhbCBvZiBuZXdseSB1bnVzZWQgZGVwZW5kZW5jaWVzIGFmdGVyIHRoZSB1cGdyYWRlCi8v
             VW5hdHRlbmRlZC1VcGdyYWRlOjpSZW1vdmUtTmV3LVVudXNlZC1EZXBlbmRlbmNpZXMgInRydWUi
             OwoKLy8gRG8gYXV0b21hdGljIHJlbW92YWwgb2YgdW51c2VkIHBhY2thZ2VzIGFmdGVyIHRoZSB1
             cGdyYWRlCi8vIChlcXVpdmFsZW50IHRvIGFwdC1nZXQgYXV0b3JlbW92ZSkKLy9VbmF0dGVuZGVk
             LVVwZ3JhZGU6OlJlbW92ZS1VbnVzZWQtRGVwZW5kZW5jaWVzICJmYWxzZSI7CgovLyBBdXRvbWF0
             aWNhbGx5IHJlYm9vdCAqV0lUSE9VVCBDT05GSVJNQVRJT04qIGlmCi8vICB0aGUgZmlsZSAvdmFy
             L3J1bi9yZWJvb3QtcmVxdWlyZWQgaXMgZm91bmQgYWZ0ZXIgdGhlIHVwZ3JhZGUKVW5hdHRlbmRl
             ZC1VcGdyYWRlOjpBdXRvbWF0aWMtUmVib290ICJ0cnVlIjsKCi8vIEF1dG9tYXRpY2FsbHkgcmVi
             b290IGV2ZW4gaWYgdGhlcmUgYXJlIHVzZXJzIGN1cnJlbnRseSBsb2dnZWQgaW4KLy8gd2hlbiBV
             bmF0dGVuZGVkLVVwZ3JhZGU6OkF1dG9tYXRpYy1SZWJvb3QgaXMgc2V0IHRvIHRydWUKLy9VbmF0
             dGVuZGVkLVVwZ3JhZGU6OkF1dG9tYXRpYy1SZWJvb3QtV2l0aFVzZXJzICJ0cnVlIjsKCi8vIElm
             IGF1dG9tYXRpYyByZWJvb3QgaXMgZW5hYmxlZCBhbmQgbmVlZGVkLCByZWJvb3QgYXQgdGhlIHNw
             ZWNpZmljCi8vIHRpbWUgaW5zdGVhZCBvZiBpbW1lZGlhdGVseQovLyAgRGVmYXVsdDogIm5vdyIK
             VW5hdHRlbmRlZC1VcGdyYWRlOjpBdXRvbWF0aWMtUmVib290LVRpbWUgIjA0OjAwIjsKCi8vIFVz
             ZSBhcHQgYmFuZHdpZHRoIGxpbWl0IGZlYXR1cmUsIHRoaXMgZXhhbXBsZSBsaW1pdHMgdGhlIGRv
             d25sb2FkCi8vIHNwZWVkIHRvIDcwa2Ivc2VjCi8vQWNxdWlyZTo6aHR0cDo6RGwtTGltaXQgIjcw
             IjsKCi8vIEVuYWJsZSBsb2dnaW5nIHRvIHN5c2xvZy4gRGVmYXVsdCBpcyBGYWxzZQovLyBVbmF0
             dGVuZGVkLVVwZ3JhZGU6OlN5c2xvZ0VuYWJsZSAiZmFsc2UiOwpVbmF0dGVuZGVkLVVwZ3JhZGU6
             OlN5c2xvZ0VuYWJsZSAidHJ1ZSI7CgovLyBTcGVjaWZ5IHN5c2xvZyBmYWNpbGl0eS4gRGVmYXVs
             dCBpcyBkYWVtb24KLy8gVW5hdHRlbmRlZC1VcGdyYWRlOjpTeXNsb2dGYWNpbGl0eSAiZGFlbW9u
             IjsKCi8vIERvd25sb2FkIGFuZCBpbnN0YWxsIHVwZ3JhZGVzIG9ubHkgb24gQUMgcG93ZXIKLy8g
             KGkuZS4gc2tpcCBvciBncmFjZWZ1bGx5IHN0b3AgdXBkYXRlcyBvbiBiYXR0ZXJ5KQovLyBVbmF0
             dGVuZGVkLVVwZ3JhZGU6Ok9ubHlPbkFDUG93ZXIgInRydWUiOwoKLy8gRG93bmxvYWQgYW5kIGlu
             c3RhbGwgdXBncmFkZXMgb25seSBvbiBub24tbWV0ZXJlZCBjb25uZWN0aW9uCi8vIChpLmUuIHNr
             aXAgb3IgZ3JhY2VmdWxseSBzdG9wIHVwZGF0ZXMgb24gYSBtZXRlcmVkIGNvbm5lY3Rpb24pCi8v
             IFVuYXR0ZW5kZWQtVXBncmFkZTo6U2tpcC1VcGRhdGVzLU9uLU1ldGVyZWQtQ29ubmVjdGlvbnMg
             InRydWUiOwoKLy8gVmVyYm9zZSBsb2dnaW5nCi8vIFVuYXR0ZW5kZWQtVXBncmFkZTo6VmVyYm9z
             ZSAiZmFsc2UiOwoKLy8gUHJpbnQgZGVidWdnaW5nIGluZm9ybWF0aW9uIGJvdGggaW4gdW5hdHRl
             bmRlZC11cGdyYWRlcyBhbmQKLy8gaW4gdW5hdHRlbmRlZC11cGdyYWRlLXNodXRkb3duCi8vIFVu
             YXR0ZW5kZWQtVXBncmFkZTo6RGVidWcgImZhbHNlIjsKCi8vIEFsbG93IHBhY2thZ2UgZG93bmdy
             YWRlIGlmIFBpbi1Qcmlvcml0eSBleGNlZWRzIDEwMDAKLy8gVW5hdHRlbmRlZC1VcGdyYWRlOjpB
             bGxvdy1kb3duZ3JhZGUgImZhbHNlIjsK
           encoding: base64
       - path: /root/.selected_editor
           content: |
             SELECTED_EDITOR="/bin/nano"
       - path: /etc/fail2ban/jail.local
           content: |
             [DEFAULT]
             ignoreip = 127.0.0.1/8 ::1
             [sshd]
             port = ssh
             enabled = true
       - path: /etc/ufw/user.rules
           content: |
             KmZpbHRlcgo6dWZ3LXVzZXItaW5wdXQgLSBbMDowXQo6dWZ3LXVzZXItb3V0cHV0IC0gWzA6MF0K
             OnVmdy11c2VyLWZvcndhcmQgLSBbMDowXQo6dWZ3LWJlZm9yZS1sb2dnaW5nLWlucHV0IC0gWzA6
             MF0KOnVmdy1iZWZvcmUtbG9nZ2luZy1vdXRwdXQgLSBbMDowXQo6dWZ3LWJlZm9yZS1sb2dnaW5n
             LWZvcndhcmQgLSBbMDowXQo6dWZ3LXVzZXItbG9nZ2luZy1pbnB1dCAtIFswOjBdCjp1ZnctdXNl
             ci1sb2dnaW5nLW91dHB1dCAtIFswOjBdCjp1ZnctdXNlci1sb2dnaW5nLWZvcndhcmQgLSBbMDow
             XQo6dWZ3LWFmdGVyLWxvZ2dpbmctaW5wdXQgLSBbMDowXQo6dWZ3LWFmdGVyLWxvZ2dpbmctb3V0
             cHV0IC0gWzA6MF0KOnVmdy1hZnRlci1sb2dnaW5nLWZvcndhcmQgLSBbMDowXQo6dWZ3LWxvZ2dp
             bmctZGVueSAtIFswOjBdCjp1ZnctbG9nZ2luZy1hbGxvdyAtIFswOjBdCjp1ZnctdXNlci1saW1p
             dCAtIFswOjBdCjp1ZnctdXNlci1saW1pdC1hY2NlcHQgLSBbMDowXQojIyMgUlVMRVMgIyMjCgoj
             IyMgdHVwbGUgIyMjIGFsbG93IHRjcCAyMiAwLjAuMC4wLzAgYW55IDAuMC4wLjAvMCBpbl9lbnAz
             czAKLUEgdWZ3LXVzZXItaW5wdXQgLWkgZW5wM3MwIC1wIHRjcCAtLWRwb3J0IDIyIC1qIEFDQ0VQ
             VAoKIyMjIEVORCBSVUxFUyAjIyMKCiMjIyBMT0dHSU5HICMjIwotQSB1ZnctYWZ0ZXItbG9nZ2lu
             Zy1pbnB1dCAtaiBMT0cgLS1sb2ctcHJlZml4ICJbVUZXIEJMT0NLXSAiIC1tIGxpbWl0IC0tbGlt
             aXQgMy9taW4gLS1saW1pdC1idXJzdCAxMAotQSB1ZnctYWZ0ZXItbG9nZ2luZy1mb3J3YXJkIC1q
             IExPRyAtLWxvZy1wcmVmaXggIltVRlcgQkxPQ0tdICIgLW0gbGltaXQgLS1saW1pdCAzL21pbiAt
             LWxpbWl0LWJ1cnN0IDEwCi1JIHVmdy1sb2dnaW5nLWRlbnkgLW0gY29ubnRyYWNrIC0tY3RzdGF0
             ZSBJTlZBTElEIC1qIFJFVFVSTiAtbSBsaW1pdCAtLWxpbWl0IDMvbWluIC0tbGltaXQtYnVyc3Qg
             MTAKLUEgdWZ3LWxvZ2dpbmctZGVueSAtaiBMT0cgLS1sb2ctcHJlZml4ICJbVUZXIEJMT0NLXSAi
             IC1tIGxpbWl0IC0tbGltaXQgMy9taW4gLS1saW1pdC1idXJzdCAxMAotQSB1ZnctbG9nZ2luZy1h
             bGxvdyAtaiBMT0cgLS1sb2ctcHJlZml4ICJbVUZXIEFMTE9XXSAiIC1tIGxpbWl0IC0tbGltaXQg
             My9taW4gLS1saW1pdC1idXJzdCAxMAojIyMgRU5EIExPR0dJTkcgIyMjCgojIyMgUkFURSBMSU1J
             VElORyAjIyMKLUEgdWZ3LXVzZXItbGltaXQgLW0gbGltaXQgLS1saW1pdCAzL21pbnV0ZSAtaiBM
             T0cgLS1sb2ctcHJlZml4ICJbVUZXIExJTUlUIEJMT0NLXSAiCi1BIHVmdy11c2VyLWxpbWl0IC1q
             IFJFSkVDVAotQSB1ZnctdXNlci1saW1pdC1hY2NlcHQgLWogQUNDRVBUCiMjIyBFTkQgUkFURSBM
             SU1JVElORyAjIyMKQ09NTUlUCg==
           encoding: base64
       - path: /etc/ufw/user6.rules
           content: |
             KmZpbHRlcgo6dWZ3Ni11c2VyLWlucHV0IC0gWzA6MF0KOnVmdzYtdXNlci1vdXRwdXQgLSBbMDow
             XQo6dWZ3Ni11c2VyLWZvcndhcmQgLSBbMDowXQo6dWZ3Ni1iZWZvcmUtbG9nZ2luZy1pbnB1dCAt
             IFswOjBdCjp1Znc2LWJlZm9yZS1sb2dnaW5nLW91dHB1dCAtIFswOjBdCjp1Znc2LWJlZm9yZS1s
             b2dnaW5nLWZvcndhcmQgLSBbMDowXQo6dWZ3Ni11c2VyLWxvZ2dpbmctaW5wdXQgLSBbMDowXQo6
             dWZ3Ni11c2VyLWxvZ2dpbmctb3V0cHV0IC0gWzA6MF0KOnVmdzYtdXNlci1sb2dnaW5nLWZvcndh             cmQgLSBbMDowXQo6dWZ3Ni1hZnRlci1sb2dnaW5nLWlucHV0IC0gWzA6MF0KOnVmdzYtYWZ0ZXIt
             bG9nZ2luZy1vdXRwdXQgLSBbMDowXQo6dWZ3Ni1hZnRlci1sb2dnaW5nLWZvcndhcmQgLSBbMDow
             XQo6dWZ3Ni1sb2dnaW5nLWRlbnkgLSBbMDowXQo6dWZ3Ni1sb2dnaW5nLWFsbG93IC0gWzA6MF0K
             OnVmdzYtdXNlci1saW1pdCAtIFswOjBdCjp1Znc2LXVzZXItbGltaXQtYWNjZXB0IC0gWzA6MF0K
             IyMjIFJVTEVTICMjIwoKIyMjIHR1cGxlICMjIyBhbGxvdyB0Y3AgMjIgOjovMCBhbnkgOjovMCBp
             bl9lbnAzczAKLUEgdWZ3Ni11c2VyLWlucHV0IC1pIGVucDNzMCAtcCB0Y3AgLS1kcG9ydCAyMiAt
             aiBBQ0NFUFQKCiMjIyBFTkQgUlVMRVMgIyMjCgojIyMgTE9HR0lORyAjIyMKLUEgdWZ3Ni1hZnRl
             ci1sb2dnaW5nLWlucHV0IC1qIExPRyAtLWxvZy1wcmVmaXggIltVRlcgQkxPQ0tdICIgLW0gbGlt
             aXQgLS1saW1pdCAzL21pbiAtLWxpbWl0LWJ1cnN0IDEwCi1BIHVmdzYtYWZ0ZXItbG9nZ2luZy1m
             b3J3YXJkIC1qIExPRyAtLWxvZy1wcmVmaXggIltVRlcgQkxPQ0tdICIgLW0gbGltaXQgLS1saW1p
             dCAzL21pbiAtLWxpbWl0LWJ1cnN0IDEwCi1JIHVmdzYtbG9nZ2luZy1kZW55IC1tIGNvbm50cmFj
             ayAtLWN0c3RhdGUgSU5WQUxJRCAtaiBSRVRVUk4gLW0gbGltaXQgLS1saW1pdCAzL21pbiAtLWxp
             bWl0LWJ1cnN0IDEwCi1BIHVmdzYtbG9nZ2luZy1kZW55IC1qIExPRyAtLWxvZy1wcmVmaXggIltV
             RlcgQkxPQ0tdICIgLW0gbGltaXQgLS1saW1pdCAzL21pbiAtLWxpbWl0LWJ1cnN0IDEwCi1BIHVm
             dzYtbG9nZ2luZy1hbGxvdyAtaiBMT0cgLS1sb2ctcHJlZml4ICJbVUZXIEFMTE9XXSAiIC1tIGxp
             bWl0IC0tbGltaXQgMy9taW4gLS1saW1pdC1idXJzdCAxMAojIyMgRU5EIExPR0dJTkcgIyMjCgoj
             IyMgUkFURSBMSU1JVElORyAjIyMKLUEgdWZ3Ni11c2VyLWxpbWl0IC1tIGxpbWl0IC0tbGltaXQg
             My9taW51dGUgLWogTE9HIC0tbG9nLXByZWZpeCAiW1VGVyBMSU1JVCBCTE9DS10gIgotQSB1Znc2
             LXVzZXItbGltaXQgLWogUkVKRUNUCi1BIHVmdzYtdXNlci1saW1pdC1hY2NlcHQgLWogQUNDRVBU
             CiMjIyBFTkQgUkFURSBMSU1JVElORyAjIyMKQ09NTUlUCg==
           encoding: base64
       runcmd:
         - "sed -i -e 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf"
         - deluser --remove-home ubuntu || true
   ```

* The ``/etc/apt/apt.conf.d/50unattended-upgrades`` above is the base64 encoded version of:

  ```C
  // Automatically upgrade packages from these (origin:archive) pairs
  //
  // Note that in Ubuntu security updates may pull in new dependencies
  // from non-security sources (e.g. chromium). By allowing the release
  // pocket these get automatically pulled in.
  Unattended-Upgrade::Allowed-Origins {
      "${distro_id}:${distro_codename}";
      "${distro_id}:${distro_codename}-security";
      // Extended Security Maintenance; doesn't necessarily exist for
      // every release and this system may not have it installed, but if
      // available, the policy for updates is such that unattended-upgrades
      // should also install from here by default.
      "${distro_id}ESMApps:${distro_codename}-apps-security";
      "${distro_id}ESM:${distro_codename}-infra-security";
      "${distro_id}:${distro_codename}-updates";
  // "${distro_id}:${distro_codename}-proposed";
  // "${distro_id}:${distro_codename}-backports";
  };

  // Python regular expressions, matching packages to exclude from upgrading
  Unattended-Upgrade::Package-Blacklist {
      // The following matches all packages starting with linux-
  //  "linux-";

      // Use $ to explicitly define the end of a package name. Without
      // the $, "libc6" would match all of them.
  //  "libc6$";
  //  "libc6-dev$";
  //  "libc6-i686$";

      // Special characters need escaping
  //  "libstdc\+\+6$";

      // The following matches packages like xen-system-amd64, xen-utils-4.1,
      // xenstore-utils and libxenstore3.0
  //  "(lib)?xen(store)?";

      // For more information about Python regular expressions, see
      // https://docs.python.org/3/howto/regex.html
  };

  // This option controls whether the development release of Ubuntu will be
  // upgraded automatically. Valid values are "true", "false", and "auto".
  Unattended-Upgrade::DevRelease "auto";

  // This option allows you to control if on a unclean dpkg exit
  // unattended-upgrades will automatically run
  //   dpkg --force-confold --configure -a
  // The default is true, to ensure updates keep getting installed
  //Unattended-Upgrade::AutoFixInterruptedDpkg "true";

  // Split the upgrade into the smallest possible chunks so that
  // they can be interrupted with SIGTERM. This makes the upgrade
  // a bit slower but it has the benefit that shutdown while a upgrade
  // is running is possible (with a small delay)
  //Unattended-Upgrade::MinimalSteps "true";

  // Install all updates when the machine is shutting down
  // instead of doing it in the background while the machine is running.
  // This will (obviously) make shutdown slower.
  // Unattended-upgrades increases logind's InhibitDelayMaxSec to 30s.
  // This allows more time for unattended-upgrades to shut down gracefully
  // or even install a few packages in InstallOnShutdown mode, but is still a
  // big step back from the 30 minutes allowed for InstallOnShutdown previously.
  // Users enabling InstallOnShutdown mode are advised to increase
  // InhibitDelayMaxSec even further, possibly to 30 minutes.
  //Unattended-Upgrade::InstallOnShutdown "false";

  // Send email to this address for problems or packages upgrades
  // If empty or unset then no email is sent, make sure that you
  // have a working mail setup on your system. A package that provides
  // 'mailx' must be installed. E.g. "user@example.com"
  Unattended-Upgrade::Mail "";

  // Set this value to one of:
  //    "always", "only-on-error" or "on-change"
  // If this is not set, then any legacy MailOnlyOnError (boolean) value
  // is used to chose between "only-on-error" and "on-change"
  // Unattended-Upgrade::MailReport "only-on-error";

  // Remove unused automatically installed kernel-related packages
  // (kernel images, kernel headers and kernel version locked tools).
  //Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

  // Do automatic removal of newly unused dependencies after the upgrade
  //Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

  // Do automatic removal of unused packages after the upgrade
  // (equivalent to apt-get autoremove)
  //Unattended-Upgrade::Remove-Unused-Dependencies "false";

  // Automatically reboot *WITHOUT CONFIRMATION* if
  //  the file /var/run/reboot-required is found after the upgrade
  Unattended-Upgrade::Automatic-Reboot "true";

  // Automatically reboot even if there are users currently logged in
  // when Unattended-Upgrade::Automatic-Reboot is set to true
  //Unattended-Upgrade::Automatic-Reboot-WithUsers "true";

  // If automatic reboot is enabled and needed, reboot at the specific
  // time instead of immediately
  //  Default: "now"
  Unattended-Upgrade::Automatic-Reboot-Time "04:00";

  // Use apt bandwidth limit feature, this example limits the download
  // speed to 70kb/sec
  //Acquire::http::Dl-Limit "70";

  // Enable logging to syslog. Default is False
  // Unattended-Upgrade::SyslogEnable "false";
  Unattended-Upgrade::SyslogEnable "true";

  // Specify syslog facility. Default is daemon
  // Unattended-Upgrade::SyslogFacility "daemon";

  // Download and install upgrades only on AC power
  // (i.e. skip or gracefully stop updates on battery)
  // Unattended-Upgrade::OnlyOnACPower "true";

  // Download and install upgrades only on non-metered connection
  // (i.e. skip or gracefully stop updates on a metered connection)
  // Unattended-Upgrade::Skip-Updates-On-Metered-Connections "true";

  // Verbose logging
  // Unattended-Upgrade::Verbose "false";

  // Print debugging information both in unattended-upgrades and
  // in unattended-upgrade-shutdown
  // Unattended-Upgrade::Debug "false";

  // Allow package downgrade if Pin-Priority exceeds 1000
  // Unattended-Upgrade::Allow-downgrade "false";
  ```

* ``/etc/ufw/user.rules`` above is base64 encoded version of

  ```text
  *filter
  :ufw-user-input - [0:0]
  :ufw-user-output - [0:0]
  :ufw-user-forward - [0:0]
  :ufw-before-logging-input - [0:0]
  :ufw-before-logging-output - [0:0]
  :ufw-before-logging-forward - [0:0]
  :ufw-user-logging-input - [0:0]
  :ufw-user-logging-output - [0:0]
  :ufw-user-logging-forward - [0:0]
  :ufw-after-logging-input - [0:0]
  :ufw-after-logging-output - [0:0]
  :ufw-after-logging-forward - [0:0]
  :ufw-logging-deny - [0:0]
  :ufw-logging-allow - [0:0]
  :ufw-user-limit - [0:0]
  :ufw-user-limit-accept - [0:0]
  ### RULES ###

  ### tuple ### allow tcp 22 0.0.0.0/0 any 0.0.0.0/0 in_enp3s0
  -A ufw-user-input -i enp3s0 -p tcp --dport 22 -j ACCEPT

  ### END RULES ###

  ### LOGGING ###
  -A ufw-after-logging-input -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -A ufw-after-logging-forward -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -I ufw-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
  -A ufw-logging-deny -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -A ufw-logging-allow -j LOG --log-prefix "[UFW ALLOW] " -m limit --limit 3/min --limit-burst 10
  ### END LOGGING ###

  ### RATE LIMITING ###
  -A ufw-user-limit -m limit --limit 3/minute -j LOG --log-prefix "[UFW LIMIT BLOCK] "
  -A ufw-user-limit -j REJECT
  -A ufw-user-limit-accept -j ACCEPT
  ### END RATE LIMITING ###
  COMMIT
  ```

* And ``/etc/ufw/user6.rules`` is the base64 encoded version of:

  ```text
  *filter
  :ufw6-user-input - [0:0]
  :ufw6-user-output - [0:0]
  :ufw6-user-forward - [0:0]
  :ufw6-before-logging-input - [0:0]
  :ufw6-before-logging-output - [0:0]
  :ufw6-before-logging-forward - [0:0]
  :ufw6-user-logging-input - [0:0]
  :ufw6-user-logging-output - [0:0]
  :ufw6-user-logging-forward - [0:0]
  :ufw6-after-logging-input - [0:0]
  :ufw6-after-logging-output - [0:0]
  :ufw6-after-logging-forward - [0:0]
  :ufw6-logging-deny - [0:0]
  :ufw6-logging-allow - [0:0]
  :ufw6-user-limit - [0:0]
  :ufw6-user-limit-accept - [0:0]
  ### RULES ###

  ### tuple ### allow tcp 22 ::/0 any ::/0 in_enp3s0
  -A ufw6-user-input -i enp3s0 -p tcp --dport 22 -j ACCEPT

  ### END RULES ###

  ### LOGGING ###
  -A ufw6-after-logging-input -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -A ufw6-after-logging-forward -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -I ufw6-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
  -A ufw6-logging-deny -j LOG --log-prefix "[UFW BLOCK] " -m limit --limit 3/min --limit-burst 10
  -A ufw6-logging-allow -j LOG --log-prefix "[UFW ALLOW] " -m limit --limit 3/min --limit-burst 10
  ### END LOGGING ###

  ### RATE LIMITING ###
  -A ufw6-user-limit -m limit --limit 3/minute -j LOG --log-prefix "[UFW LIMIT BLOCK] "
  -A ufw6-user-limit -j REJECT
  -A ufw6-user-limit-accept -j ACCEPT
  ### END RATE LIMITING ###
  COMMIT
  ```

* We base64 encode large text files in the YAML above in order to avoid possible issues with files being parsed incorrectly (i.e. not simply taken verbatim), which can occur when the YAML is processed.
* You will want to change the ``hashed_passwd`` above to the hash of a password you know.  See the [Ansible docs on creating a password for the user module](https://docs.ansible.com/ansible/2.7/reference_appendices/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module) for a number of way of solving this common problem.
* You will also need to substitute you own SSH public key for the one in the ``ssh_authorized_keys`` section above.
* Finally, you may need to change ``enps3s0`` in the UFW rules above (including base64 encoding the results, and replacing the base64 included version in ``user-data`` above).

### Perform the (mostly) automated install

* This is only a _mostly_ automated install because the install gives you a chance to manage your storage devices, which could cause loss of data or failed install. This could be automated as well, if it were needed and could be managed in a safe way in your environment.

1. Attach a keyboard and monitor to the NUC(-like) device
2. Attach both USB sticks to the NUC(-like) device
3. As the device boots press the that allows you to choose an alternate boot device — often this is ``F7``, ``F8``, or ``F9``. If you are not sure of this key, you may need to boot a few time to figure out the appropriate key to press.  If you need to get into BIOS setup mode (which often also lets you choose which device from which to boot), you may need to press ``Del``, ``F2``, ``F10``, ``F12``, or ``Esc`` (depending on your hardware).
4. Choose to boot from the USB stick with the Ubuntu Server 20.04 LTS install media.
5. When prompted, choose your language (or closest available; cloud-init will use the locale you specified for the final locale, but your final locale may not be available as an installer locale).
6. When prompted, configure your storage as desired.
7. When prompted, reboot. Wait until prompted to remove the install media (and auto-install stick).
   1. You will have the option to reboot before the final prompt; do not do so, instead wait until you see "Install Complete!" in the header at the top of the installer screen.  At that point, select 'Reboot now'.
8. On first reboot, do no not log in immediately. After a short period of waiting, you will noticed that 'cloud-init' is applying the final parts of the configuration from the 'auto-install' YAML. (It doesn't all happen in the installer phase).
9. Once 'cloud-init final' is reached, it is safe to login, and expect everything to be configured as you specified.

## Install and configure backups (recommended)

For this article we will use ``restic`` because it allows backing up to a variety of remote storage types.

* It is recommended to minimize how much of the backing up is done while 'root'. Therefore, where possible, one should use the restic command as the user that 'owns' the data.
* While the description below is for data requiring root access or the [appropriate capability](https://restic.readthedocs.io/en/stable/080_examples.html#full-backup-without-root). We don't use the capability option here, because the capability setting will be lost if ``apt`` updates the binary (e.g. due to bug fix).
* It is recommended to not use environment variables for sensitive information such as passwords because the environment can be viewed with ``ps e`` (e.g. ``ps auex``)

To backup the main OS and OS data (e.g. /etc, most of /var, /local-home, /root)

1. ``sudo -sH``
2. ``cd ~``
3. ``mkdir restic-files``
4. ``cd restic-files``
5. ``chmod 700 .``
6. ``touch password-file``
7. ``chmod 600 password-file``
8. ``sensible-editor password-file``
9. In the editor, add a strong password (e.g. 30 alphanumeric and special characters), then save and close (having a file with the password not ideal, but avoiding it is rather complicated, and out of scope for this article).
10. If using SFTP for backups, create a passwordless SSH keypair using:
    1. ``ssh-keygen -t rsa -f restic@piserver -C restic@piserver -N ''``
    2. Copy the contents of ``restic@piserver.pub`` to you destination's ``authorized_keys`` file.
11. [Initialize your destination restic repository](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html)
12. [Do an initial backup](https://restic.readthedocs.io/en/stable/040_backup.html)
    1. (assuming you have configured, ``~/.ssh/config`` so that ``restic@backupserver.example.com`` uses the ``restic@piserver`` created above:  

       ```bash
       restic -r sftp:restic@backupserver.example.com:/path/to/repo  --password-file ./password-file backup --one-file-system --exclude /var/cache/apt --cleanup-cache /etc /var /local-home /root
       ```

13. Now create a crontab entry to do this once a day:
    1. ``crontab -e``
    2. Add an entry such as:

       ```crontab
       23  2  *   *   *  restic -r sftp:restic@backupserver.example.com:/path/to/repo --password-file ~/password-file backup --one-file-system --cleanup-cache --exclude /var/cache/apt --quiet /etc /var /local-home /root 2>&1 | logger -t restic
       ```

    3. Save and exit the editor
14. ``exit``

For other backups, use similar steps, but using ``sudo -u data-owner -s`` (where data-owner is the user that 'owns' the data to be backed up).

## Install & configure the desired services

This is basically an Ubuntu system so the many guides for installing and configuring services on Ubuntu (and, in many cases, Debian) will be applicable.

**Enjoy!**
