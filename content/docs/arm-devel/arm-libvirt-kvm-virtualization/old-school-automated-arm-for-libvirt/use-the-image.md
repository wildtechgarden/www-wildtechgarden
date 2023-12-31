---
slug: use-the-image
aliases:
    - /docs/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/use-the-image/
    - /docs/devel/arm-devel/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/use-the-image/
    - /develop-design/arm-development/arm-libvirt-kvm-virtualization/old-school-automated-arm-for-libvirt/use-the-image/
    - /devel/old-school-automated-arm-for-libvirt/use-the-image/
title: "Use the old school ARM image (and boot files)"
author: Daniel F. Dickinson
series:
    - arm-libvirt-kvm-virtualization
tags:
    - arm-devel
    - debian
    - devel
    - firmware
    - linux
    - sysadmin-devops
    - virtualization
date: '2020-11-13T13:50:00+00:00'
publishDate: '2020-11-13T13:50:00+00:00'
description: Use an non-EFI (old school) ARM Hard Float image for Libvirt/KVM.
summary: Use an non-EFI (old school) ARM Hard Float image for Libvirt/KVM.
---

{{< details-toc >}}

## Option 1: Use the Image Directly (not recommended)

### Upload kernel, initrd, and packer image using virsh

1. ```bash
   ls -al vmlinuz* initrd.gz* *.qcow2
   ```

2. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name vmlinuz-x.x.x-x-armmp-lpae --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

3. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol vmlinuz-x.x.x.x-x --file vmlinuz-x.x.x.x-x
   ```

4. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name initrd.img-x.x.x-x-armmp-lpae --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

5. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol initrd.img-x.x.x-x-armmp-lpae --file initrd.img-x.x.x-x-armmp-lpae
   ```

6. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name preseeded-armhf-no-efi-image-preseed-image-xxxx-xx-xx-xx-xx.qcow2 --format qcow2 --allocation <size-from-ls> --capacity <size-from-ls>
   ```

7. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol preseeded-armhf-no-efi-image-preseed-image-xxxx-xx-xx-xx-xx.qcow2 --file preseeded-armhf-no-efi-image-preseed-image-xxxx-xx-xx-xx-xx.qcow2
   ```

### Create the ARM VM using Virtual Machine Manager

1. Launch “Virtual Machine Manager” (virt-manager from the command line).
2. Select ‘File|New Virtual Machine’
3. Select ‘Import existing disk image’
4. Change ‘Architecture options’ to Architecture: ‘arm’, Machine Type: ‘virt-2.12’. *(virt-3.0 and
virt-3.1 are known to not work with this guide; newer and older versions likely will work)*.
5. Select ‘Browse…’, select a virtual image you uploaded above, and select ‘Choose Volume’.
    1. Alternatively, if you want to use this image for more than one virtual machine, then
    create a new virtual hard drive and use the uploaded virtual image as a ‘backing store’.

6. For each of the kernel and initrd, browse to the file and select ‘Choose Volume’.
7. Set ‘Kernel args’ to ‘elevator=noop noresume root=/dev/vda1’.
8. Set the operating system to ‘Debian10’
9. Select ‘Forward’
10. Configure the amount of memory and cpus (max 4) and select ‘Forward’
11. Set the VM name.
12. Select the appropriate network device for your virtual hosting setup.
13. Click ‘Finish’
14. You’ve now created a virtual machine using the image you uploaded.

## Option 2: Feed the Image to a Packer Provisioning Run

You need a few files:

### Packer Template

You could name this ``qemu-ansible-armhf-blog-no-efi-template.json``

```json
{
    "variables": {
        "accelerator": "none",
        "admin_password": "Should fail unless overridden via other variable input.",
        "admin_user": "example-admin",
        "armhf_kernel": "",
        "armhf_initrd": "",
        "build_time": "{{isotime "2006-01-02-15-04"}}",
        "domain": "",
        "hostname": "",
        "iso_checksum": "",
        "iso_checksum_type": "sha512",
        "iso_src_url_prefix": "",
        "iso_name": "",
        "machine_type": "virt",
        "memory_size": "1024",
        "os_disk_size": "8192",
        "output_compression": "true",
        "output_format": "qcow2",
        "provisioning_groups": "",
        "ssh_boot_password": "example-provision-password",
        "vm_name_suffix": "-os.qcow2"
    },
    "sensitive-variables": [
        "admin_password",
        "ssh_boot_password"
    ],
    "builders": [
        {
            "type": "qemu",
            "accelerator": "{{ user `accelerator` }}",
            "cpus": 4,
            "disable_vnc": true,
            "disk_compression":"{{ user `output_compression` }}",
            "disk_image": true,
            "disk_size": "{{ user `os_disk_size` }}",
            "headless": true,
            "format": "{{ user `output_format` }}",
            "iso_checksum": "{{ user `iso_checksum_type` }}:{{ user `iso_checksum` }}",
            "iso_target_extension": "qcow2",
            "iso_url": "{{ user `iso_src_url_prefix` }}/{{ user `iso_name` }}",
            "machine_type": "{{ user `machine_type` }}",
            "memory": "{{ user `memory_size` }}",
            "net_device": "virtio-net-pci",
            "output_directory": "output/output-armhf-no-efi-{{ user `hostname` }}-{{user `build_time`}}",
            "qemuargs": [
                [ "-display", "none" ],
                [ "-kernel", "{{ user `armhf_kernel` }}" ],
                [ "-initrd", "{{ user `armhf_initrd` }}" ],
                [ "-boot", "menu=off,order=dc,strict=on" ],
                [ "-serial", "mon:pty" ],
                [ "-append", "elevator=noop noresume root=/dev/vda1" ]
            ],
            "qemu_binary": "qemu-system-arm",
            "shutdown_command": "su -c '( sleep 10 && echo {{ user `admin_password` }} ) | sudo -u root -S shutdown -P now' {{ user `admin_user` }}",
            "ssh_password": "{{ user `ssh_boot_password` }}",
            "ssh_timeout": "10m",
            "ssh_username": "root",
            "use_backing_file": false,
            "vm_name": "{{ user `hostname` }}{{ user `vm_name_suffix` }}"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "expect_disconnect": true,
            "inline": [
                "hostnamectl set-hostname {{ user `hostname` }}",
                "sed -i -e '1,$s/preseed-image/{{ user `hostname` }}/g' /etc/hosts",
                "systemctl reboot"
            ]
        },
        {
        "type": "ansible",
        "groups": "{{ user `provisioning_groups` }}",
        "host_alias": "{{ user `hostname` }}.{{ user `domain` }}",
        "playbook_file": "playbook-armhf-no-efi-blog-example.yml",
        "user": "root"
        }
    ]
}
```

### A Packer ‘var-file’

You could name this ``arm-devel-blog-var-file.json``

```json
{
    "accelerator": "tcg",
    "armhf_kernel": "/home/user/Documents/Artifacts/preseeded-armhf-no-efi-image-preseed-image-2020-11-11-10-29/vmlinuz-4.19.0-12-armmp-lpae",
    "armhf_initrd": "/home/user/Documents/Artifacts/preseeded-armhf-no-efi-image-preseed-image-2020-11-11-10-29/initrd.img-4.19.0-12-armmp-lpae",
    "admin_user": "example-admin",
    "domain": "example.net",
    "hostname": "arm-devel",
    "iso_checksum": "6aeecc54be02d3cf51e65dd6f592c7f6b4c3d4ad7663cbdd824f2d895f5509bcee9ec9c858d79b7bb97071a0f24a4ab6144c992fe8a6101d96fa8d0922645532",
    "iso_checksum_type": "sha512",
    "iso_src_url_prefix": "file:///home/user/Documents/Artifacts/preseeded-armhf-no-efi-image-preseed-image-2020-11-11-10-29/",
    "iso_name": "preseed-image-armhf-no-efi-buster-packer.qcow2",
    "machine_type": "virt-2.12",
    "memory_size": "2048",
    "os_disk_size": "8192",
    "output_compression": "true",
    "output_format": "qcow2",
    "provisioning_groups": "dhcp",
    "vm_name_suffix": "-os.qcow2"
}
```

### Admin Password Var File

You could call this password-var-file.json. I recommend you do NOT place this
version control, and that you make it readable by the user only (e.g.
chmod 600 password-var-file.json), and that you delete it when finished
creating the image.

```json
{
    "admin_password": "example-admin-password"
}
```

### Ansible Playbook and Support Files

* The following is a very simple ansible playbook for demonstration purposes as the use of [Ansible](https://www.ansible.com/) is beyond the scope of this article.
* Also note that [Packer can use many provisioners](https://developer.hashicorp.com/packer/docs/provisioners), so if you don’t like Ansible you have other choices.
* **NB** Password *really* shouldn’t be included in playbooks.
  * You should use the [ansible ‘vault’](https://docs.ansible.com/ansible/latest/vault_guide/index.html#playbooks-vault) with [encrypted passwords](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module).
* This playbook assumes you have an SSH public/private keypair in your home directory’s .ssh subdirectory. If this is not true, please generate one with ssh-keygen -t rsa.
* You should name this ``playbook-armhf-no-efi-blog-example.yml``.

```yaml
- hosts: all
  vars:
    admin_user_name: example-admin
    admin_user_password: example-admin-password
    admin_groups:
    - sudo
    - adm
    - operator
    - staff
    first_user_name: example-user
    first_user_password: example-user-password
    first_user_groups:
    - users
  tasks:
  - name: Configure local admin user
    tags:
    - admin_user
    - ssh
    become: yes
    block:
      - name: Configure group for local admin user
        group:
        name: "{{ admin_user_name }}"
        system: yes
        state: present
        - name: Add local admin user system groups
        group:
        name: "{{ item }}"
        system: yes
        state: present
        loop: "{{ admin_groups | union(['{{ admin_user_name }}'] ) }}"
        - name: Configure local admin user
        user:
        name: "{{ admin_user_name }}"
        password: "{{ admin_user_password | password_hash('sha512') }}"
        system: yes
        create_home: yes
        expires:
        shell: "/bin/bash"
        group: "{{ admin_user_group_name | default(admin_user_name) }}"
        groups: "{{ admin_groups }}"
        state: present
        - name: Configure SSH authorized keys for local admin user
        vars:
        admin_user_public_key:
        - ~/.ssh/id_rsa.pub
        authorized_key:
        user: "{{ admin_user_name }}"
        state: present
        key: "{{ lookup('file', lookup('first_found', admin_user_public_key)) }}"
        exclusive: True

  - name: Install QEMU guest agent
    apt:
    name: "qemu-guest-agent"
    state: present

  - name: Configure local regular user
    tags:
    - regular_user
    - ssh
    become: yes
    block:
        - name: Configure group for first regular user
          group:
            name: "{{ first_user_name }}"
            state: present
        - name: Add first regular user system groups
          group:
            name: "{{ item }}"
            system: yes
            state: present
            loop: "{{ first_user_groups }}"
        - name: Configure first regular user
          user:
            name: "{{ first_user_name }}"
            password: "{{ first_user_password | password_hash('sha512') }}"
            comment: "{{ first_user_comment | default(omit) }}"
            create_home: yes
            expires:
            shell: "/bin/bash"
            group: "{{ first_user_name }}"
            groups: "{{ first_user_groups }}"
            state: present
        - name: Configure SSH authorized keys for local admin user
          vars:
            first_user_public_key:
            - ~/.ssh/id_rsa.pub
            authorized_key:
            user: "{{ first_user_name }}"
            state: present
            key: "{{ lookup('file', lookup('first_found', first_user_public_key)) }}"
            exclusive: True

  - name: Install packages for debian family hosts
    become: yes
    vars:
    devel_packages:
    -  autoconf
    -  autoconf-doc
    -  automake
    -  autopoint
    -  autotools-dev
    -  build-essential
    -  debootstrap
    -  fakechroot
    -  fakeroot
    -  gawk
    -  libncurses-dev
    -  libncurses5-dev
    -  libncursesw5-dev
    -  quilt
    apt:
        name: "{{ devel_packages }}"
        state: present

  - name: Add ifupdown configs as appropriate
    vars:
      iface_fragments:
        enp1s0:
        inet6_type: auto
        become: yes
    block:
    - name: Add ifupdown and related packages
        apt:
        name:
        - ifupdown
        - ethtool
        - isc-dhcp-client
        state: present
  - name: Add configuration for ifupdown
    block:
      - name: Add base interfaces file
        copy:
            src: interfaces
            dest: /etc/network/interfaces
            owner: root
            group: root
            mode: 0644
      - name: Create interfaces fragments directory
        file:
            path: /etc/network/interfaces.d
            owner: root
            group: root
            mode: 0755
            state: directory
      -  name: Add interfaces fragments files
            template:
                src: interfaces.d.j2
                dest: "/etc/network/interfaces.d/{{ item.key }}"
                owner: root
                group: root
                mode: 0644
            loop: "{{ iface_fragments|default({})|dict2items }}"

  - name: Configure SSH
    become: yes
    block:
      - name: Add final sshd_config
        copy:
        dest: /etc/ssh/sshd_config
        owner: root
        group: root
        mode: 0755
        src: "sshd_config.sample"

  - name: Configure local root user
    tags:
     - root_user
    become: yes
    user:
        name: "{{ root_user_name | default('root') }}"
        password: "{{ root_user_password | default('*') }}"
        state: present
```

#### Support File: SSH Server Config

This should be in the files subdirectory and named sshd_config.sample.

```plain
# $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file. See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented. Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
PermitRootLogin no
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunnelled clear text passwords, change to no here!
#PasswordAuthentication yes
PasswordAuthentication no
#PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication. Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem sftp /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
# X11Forwarding no
# AllowTcpForwarding no
# PermitTTY no
# ForceCommand cvs server
```

#### Support File: Network Configuration (interfaces) File

This should be in the templates subdirectory and named interfaces.d.j2

```jinja
# {{ ansible_managed }}

auto {{ item.key }}
allow-hotplug {{ item.key }}

iface {{ item.key }} inet {{ item.value['inet_type'] | default((inventory_hostname in groups['dhcp']) | ternary ('dhcp','static')) }}
{% if item.value['bridge_ports'] is defined %}
  bridge_ports {{ item.value['bridge_ports'] }}
{% endif -%}
{% if item.value['bridge_vlan_aware'] is defined %}
  bridge_vlan_aware {{ item.value['bridge_vlan_aware'] | ternary('on','off') }}
{% endif -%}
{% if item.value['addresses'] is defined -%}
{%- for aitem in item.value['addresses'] %}
  address {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['gateways'] is defined -%}
{%- for aitem in item.value['gateways'] %}
  gateway {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['ups'] is defined -%}
{%- for aitem in item.value['ups'] %}
  up {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['downs'] is defined -%}
{%- for aitem in item.value['downs'] %}
  down {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['extrav4block'] is defined %}
  {{ item.value['extrav4block'] }}
{% endif %}

{% if item.value['inet6_type'] is defined %}
iface {{ item.key }} inet6 {{ item.value['inet6_type'] }}
{% if item.value['bridge_ports'] is defined %}
  bridge_ports {{ item.value['bridge_ports'] }}
{% endif -%}
{%- if item.value['bridge_vlan_aware'] is defined %}
  bridge_vlan_aware {{ item.value['bridge_vlan_aware'] | ternary('on','off')}}
{% endif -%}
{% if item.value['v6addresses'] is defined -%}
{%- for aitem in item.value['v6addresses'] %}
  address {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['v6gateways'] is defined -%}
{%- for aitem in item.value['v6gateways'] %}
  gateway {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['v6ups'] is defined -%}
{%- for aitem in item.value['v6ups'] %}
  up {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['v6downs'] is defined -%}
{%- for aitem in item.value['v6downs'] %}
  down {{ aitem }}
{% endfor -%}
{% endif -%}
{% if item.value['extrav6block'] is defined %}
  {{ item.value['extrav6block'] }}
{% endif -%}
{% endif -%}
```

### Optional: A serial terminal

* If you want to watch the virtual machines boot screens you will need a serial terminal program that works with a Linux pty as the serial input/output. picocom is a good choice. Unlike the preseed phase, very little actually happens on this terminal.
* I recommend omitting PACKER_LOG=1 in the command below and not bothering to watch the terminal; this will also make the provisioning output much easier to read.

### Execute Packer Command

1. ```bash
   Execute PACKER_LOG=1 packer build -var-file arm-devel-var-file.json -var-file password-var-file.json qemu-ansible-armhf-no-efi-template.json
   ```

2. The packer command will take a while (probably over ten minutes). To watch the progress point your serial terminal program at the PTY device with baud rate 115200, pointed to by the line Qemu stdout: char device redirected to /dev/pts/xin the packer output. ‘x’ will be a number. For example ``picocom -b 115200 /dev/pts/3`` if x was 3.

### Extract the Kernel and Initramfs (vmlinuz and initrd.img)

1. Change to the output directory containing the generated image.
2. Execute ``guestfish -i -a <name-of-image-file>``
3. Execute ``ls /boot`` to find the names of the newest vmlinuz and initrd.img (you don’t want the plain vmlinuz and initrd.img because they are just symlinks).
4. Execute

   ```bash
   copy-out /boot/vmlinuz-x.x.x-x-armmp-lpae /boot/initrd.img-x.x.x-x-armmp-lpae ./
   ```

5. Execute ``exit``

### Use the Image (and boot files)

#### Upload kernel, initrd, and instance image using virsh

1. ```bash
   ls -al vmlinuz* initrd.gz* *.qcow2
   ```

2. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name vmlinuz-x.x.x-x-armmp-lpae --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

3. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol vmlinuz-x.x.x.x-x --file vmlinuz-x.x.x.x-x
   ```

4. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name initrd.img-x.x.x-x-armmp-lpae --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

5. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol initrd.img-x.x.x-x-armmp-lpae --file initrd.img-x.x.x-x-armmp-lpae
   ```

6. ```bash
   virsh -c qemu+ssh://user@host/system vol-create-as --pool default --name arm-blog-devel-blog-os.qcow2 --format raw --allocation <size-from-ls> --capacity <size-from-ls>
   ```

7. ```bash
   virsh -c qemu+ssh://user@host/system vol-upload --pool default --vol arm-blog-devel-blog-os.qcow2 --file arm-blog-devel-blog-os.qcow2
   ```

#### Create the ARM VM Instance using Virtual Machine Manager

1. Launch “Virtual Machine Manager” (virt-manager from the command line).
2. Select ‘File|New Virtual Machine’
3. Select ‘Import existing disk image’
4. Change ‘Architecture options’ to Architecture: ‘arm’, Machine Type: ‘virt-2.12’. *(virt-3.0 and
virt-3.1 are known to not work with this guide; newer and older versions likely will work)*.
5. Select ‘Browse…’, select a virtual image you uploaded above, and select ‘Choose Volume’.
    `. Alternatively, if you want to use this image for more than one virtual machine, then
    create a new virtual hard drive and use the uploaded virtual image as a ‘backing store’.
6. For each of the kernel and initrd, browse to the file and select ‘Choose Volume’.
7. Set ‘Kernel args’ to ‘elevator=noop noresume root=/dev/vda1’.
8. Set the operating system to ‘Debian10’
9. Select ‘Forward’
10. Configure the amount of memory and cpus (max 4) and select ‘Forward’
11. Set the VM name.
12. Select the appropriate network device for your virtual hosting setup.
13. Click ‘Finish’
14. You’ve now created a virtual machine using the image you uploaded.

* You should be able ssh into virtual machine as either example-admin or example-user depending
on whether you want to be an admin user or a standard user.
* The example-admin user’s password is example-admin-password, and
the example-user user’s password is example-user-password.
* If the virtual machine is not responding on the network, you will need to
login to the console (e.g. using virt-manager / VMM) and check that the
network configuration is using the right interface.
