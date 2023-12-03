---
slug: ubuntu-cloud-images-on-hyper-v
aliases:
    - /docs/sysadmin-devops/windows-and-linux/ubuntu-cloud-images-on-hyper-v/
    - /sysadmin-devops/windows-and-linux/ubuntu-cloud-images-on-hyper-v/
    - /deploy-admin/ubuntu-cloud-images-on-hyper-v/
    - /docs/deploy-admin/windows-and-linux/ubuntu-cloud-images-on-hyper-v/
    - /deploy-admin/windows-and-linux/ubuntu-cloud-images-on-hyper-v/
title: "Ubuntu cloud images on Hyper-V"
date: '2021-06-24T10:32:00-04:00'
publishDate: '2020-06-24T10:32:00-04:00'
tags:
- linux
- sysadmin-devops
- virtualization
- windows
author: Daniel F. Dickinson
description: "The official Ubuntu images that are built for Azure/Hyper-V really are only compatible with Hyper-V on Azure, but there is a solution…"
summary: "The official Ubuntu images that are built for Azure/Hyper-V really are only compatible with Hyper-V on Azure, but there is a solution…"
frontCard: true
card: true
---

{{< details-toc >}}

## Preface

The official Ubuntu images that are built for Azure/Hyper-V really are only compatible with Hyper-V on Azure, despite Canonical (the company behind Ubuntu) offering Azure/Hyper-V disk images at [Ubuntu Daily cloud images - Focal](http://cloud-images.ubuntu.com/focal/current/). There is a solution, and this page describes using it a mostly automated way using [Packer](https://www.packer.io/).

## The issue

The Hyper-V images do not work with local / on-premises (Windows 10 / Windows Server 20xx) Hyper-V setups due to the included cloud-init only being configured to use the Azure datasource. This means you cannot set a password or SSH key and therefore cannot login to the resulting instance. The page I found that helped the most ([Enable Hyper-V Integration Services for your Ubuntu guest VMs](https://blog.jitdor.com/2020/02/08/enable-hyper-v-integration-services-for-your-ubuntu-guest-vms/)) involves 'manually' modifying a generic Ubuntu cloud image, and I haven't seen automated solutions for this, so I experimented, and now document my solution here.

## Requirements to solve the issue

1. Obtain a generic Ubuntu cloud image such as the [daily Ubuntu LTS 20.04 (Focal Fossa) generic cloud image](http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img)
2. Modify the image to
   1. Load the required kernel modules
      1. The modules are:
         * ``hv_balloon``
         * ``hv_utils``
         * ``hv_vmbus``
         * ``hv_sock``
         * ``hv_storvsc``
         * ``hv_netvsc``
   2. Add the ``linux-cloud-tools-generic`` package to the image (this has the Hyper-V client daemons).

## An (mostly) automated solution

### Prerequisites for automation

The solution described here assumes you already have and know how to use [Packer](https://www.packer.io/).

Further we assume the user running packer is a member of the 'Hyper-V Administrators' group.

### Convert the generic Ubuntu cloud image to VHDX

#### Option 1: Using qemu-img in WSL/WLS2

Note that qemu-img for Windows currently has a [known issue with vhdx files](https://gitlab.com/qemu-project/qemu/-/issues/250) which is why we don't use the native (Windows) version of qemu-img here.

1. Make sure ``qemu-utils`` is installed in your WSL/WSL2
   1. Assuming Debian/Ubuntu WSL/WSL2, from a windows command prompt (Powershell or CMD) use: ``bash -c "apt update && apt install -y qemu-utils``
2. Convert the image: ``bash -c "qemu-img convert -p -f qcow2 -O vhdx focal-server-cloudimg-amd64.img focal-server-cloudimg-amd64.vhdx"``
   * If automating you probably want to replace ``-p`` with ``-q`` (quiet instead of progress).

#### Option2: Using vbox-img and ``Convert-VHD``

1. Make sure you have VirtualBox installed and in your PATH
2. Convert the image from qcow2 to VHD using vbox-img
   1. ``vbox-img convert --srcfilename .\focal-server-cloudimg-amd64.img --dstfilename .\focal-server-cloudimg-amd64.vhd --srcformat qcow --dstformat vhd``
3. Convert the image from VHD to VHDX using ``Convert-VHD`` (Powershell cmdlet for Hyper-V)
   1. ``Convert-VHD -Path .\focal-server-cloudimg-amd64.vhd -DestinationPath .\focal-server-cloudimg-amd64.vhdx -VHDType Dynamic``
   2. As an alternative you could use the Hyper-V Manager 'Edit Disk' GUI

### Create the required HCL2 template and files

In the directory on which you plan on working place the files below and open a Powershell console.

#### Prerequisites for using Packer

* First place the generic image in a known location such as ``C:\Users\Public\Documents``.
* Hyper-V must be configured with an **external** network switch available.

Determine it's SHA256 File Hash with (in a powershell console) ``Get-FileHash C:\Users\Public\Documents\focal-server-cloudimg-amd64.vhdx -OutVariable ov; $env:PKR_VAR_cloudimg_hash = $ov.Hash``. Use the same powershell console as for the ``packer`` command below (so that environment variable is available to Packer).

#### The main template

``hyperv-iso-packer-template.pkr.hcl``

```hcl
variable "cloudimg_hash" {
    type = string
}

source "hyperv-iso" "ubuntu_hyperv_cloud_focal_amd64" {
  disk_block_size = 1
  cd_files          = [ "./files/meta-data", "./files/user-data" ]
  cd_label          = "cidata"
  enable_dynamic_memory = true
  enable_secure_boot = true
  generation        = 2
  headless          = true
  iso_checksum      = "sha256:${var.cloudimg_hash}"
  iso_url           = "file:///Users/Public/Documents/focal-server-cloudimg-amd64.vhdx"
  iso_target_extension = "vhdx"
  output_directory  = "output/ubuntu-focal-hyperv"
  secure_boot_template = "MicrosoftUEFICertificateAuthority"
  ssh_private_key_file = "./files/private/provision"
  ssh_username      = "newadmin"
  ssh_timeout       = "10m"
  vm_name           = "myhost-ubuntu-focal-hyperv"
}

build {
  sources = ["source.hyperv-iso.ubuntu_hyperv_cloud_focal_amd64"]

  provisioner "file" {
    destination = "/local-home/newadmin"
    source = "files/newadmin/"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "while ! dpkg --status whois 2>/dev/null >/dev/null; do echo 'Waiting 2 minutes for package install to complete'; sleep 120; done"
    ]
  }

  provisioner "shell" {
    pause_before = "1m"
    inline = [
      "chmod 0700 /local-home/newadmin/.ssh",
      "chmod 0600 /local-home/newadmin/.ssh/authorized_keys",
      "sync"
    ]
  }
}
```

##### An update note on generating the 'cloud-init' ISO/CD

Since the fall of 2021[^1], you have been able to use a [`cd_content`](https://www.packer.io/plugins/builders/hyperv/iso#cd_content)
entry alongside `cd_files` which allows you to use the `templatefile` function
to generate the `user-data`, `meta-data`, and/or `vendor-data` files.

This is much more convenient when one wishes to create customised images.

#### Cloud-init files

``files\meta-data``

```yaml
instance-id: iid-myhost-01
local-hostname: myhost
```

``files\user-data``

```yaml
#cloud-config
disable_root: true
preserve_hostname: false
manage_etc_hosts: true
hostname: myhost
fqdn: myhost.example.com
ssh_pwauth: false
users:
  - name: newadmin
    groups:
      - adm
      - staff
      - sudo
    homedir: /local-home/newadmin
    lock_passwd: false
    hashed_passwd: $6$rounds=4096$Uai52ED7FnpSxVd1$iY6tuSJ2dpm1Owa41NUSvp/H1M39ZnVjiP9OWK3r9I/mm4lV.vaHlUodCWQOUGv9paOHZa8gh/9MX4.It6cAH/
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+6RqT4MKcZhb9MXlKtCaynVqYFq1zw2RrCew3w+wpcl9x4m70a/vKpyp4O4qknmpeHGYNQt+3YXEIJI4tFZLXRxmB8tOwutn7zAAeuxVdZ+mEd33bUnrxStSaO5nqtGtWumXb7sKOFHuOtecXxpfVt2/1Po35evfwIiztMBni4WEJ+13HQakpQ3eo6KDfNtozgNQpgvwoQZ/f0NS99GggL+QRP4Z71iuxSSC7Eb2p3pZZzS8gkOKUOnKCI4aVWCk1oK4S3gvsnr437ULVv+UUG0VrNCofciaX7/dvgBvMDfmsNQ8SFHZJIvI+chMKbPE9SCT/n/SYA0NEi/u5n7w8R3fZmFjyM2SQe7vpA1brYd6Od4v+Zq8TNBn5sDiWkkeqTIjqQ42JNdytHj69L68JXwoSUw7zqovl2MW4VWvKwvbXX47JAMk7S6vnjC7uKDpXimZ9o5lKkMWMPEgFA9PFCI+X9amK6WxXnUPI+f3YqmMCD4oEV7e/FTQB7TVCcF8= provision@example
ntp:
  ntp_client: auto
  enabled: true
package_update: true
package_upgrade: true
packages:
  - linux-cloud-tools-generic
  - linux-tools-generic
  - linux-generic
  - whois
package_reboot_if_required: false
bootcmd:
  - modprobe hv_balloon
  - modprobe hv_utils
  - modprobe hv_vmbus
  - modprobe hv_sock
  - modprobe hv_storvsc
  - modprobe hv_netvsc
  - sh -c 'echo "hv_balloon\nhv_utils\nhv_vmbus\nhv_sock\nhv_storvsc\nhv_netvsc" >>/etc/initramfs-tools/modules' && update-initramfs -k all -u
write_files:
  - path: /etc/ssh/sshd_config.d/pubkey_only.conf
    content: |
      PasswordAuthentication no
      PubkeyAuthentication yes
runcmd:
  - systemctl reboot
```

##### Data files used with those cloud-init files

``files\private\provision``

Contains the OpenSSH private key for the public key deploy via cloud-init,
above.

``files\newadmin\.ssh\authorized_keys``

Make the contents of the this file the SSH public key with which you plan on logging in when using the image.

### Validate the template/configuration

Execute ``packer validate .``

You can safe ignore the following message (we use ``sync`` to ensure no data is lost)

```text
Warning: A shutdown_command was not specified. Without a shutdown command, Packer
will forcibly halt the virtual machine, which may result in data loss.

  on hyperv-iso-packer-template.pkr.hcl line 5:
  (source code not available)
```

If that is the only error message you may proceed to the building the 'local Hyper-V ready' image.

### Build the 'local Hyper-V ready' image

Execute ``packer build .``

### Successful completion

At the end of a successful build you should see messages like:

```text
==> Wait completed after 4 minutes 59 seconds

==> Builds finished. The artifacts of successful builds are:
--> hyperv-iso.ubuntu_hyperv_cloud_focal_amd64: VM files in directory: output/ubuntu-focal-hyperv
```

``.\output\ubuntu-focal-hyperv\Virtual Machines`` should now contain a Hyper-V virtual machine that you can import into a local Hyper-V, and ``.\output\ubuntu-focal-hyperv\Virtual Hard Disks`` should contain the virtual hard disk for said virtual machine. The virtual hard disk file should also be able to copied to a local Hyper-V and used if you create an appropriate configuration.

### One caveat

If you boot the resulting image without using cloud-init (i.e. without a userdata metadata ISO attached) the network may not start correctly until you login to the console and modify ``/etc/netplan/50-cloud-init.conf`` so that the ``macaddress`` matches the MAC address of the VM you create (e.g. if you copy or clone when importing instead of keeping the same id as was used when building the image with Packer).

## Conclusion

Despite the difficulty finding information on how to make this work it's actually not that onerous once you know what you need, and now that you have a basic Packer build you can make additions / changes that suit your particular environment. As long as you avoiding baking 'secrets' into the image (a temporary token that allows accessing something like [Vault](https://www.vaultproject.io/) via scripts that pull the secrets into the live instance which you bake into the image is more secure) you should be 'golden'.

## Addendum (August 18, 2022)

[There is a nice answer on reddit that links to a number of different ways of provisioning Ubuntu on a local Hyper-V](https://www.reddit.com/r/devops/comments/vergfl/automate_creation_and_provisioning_of_ubuntu_vm/) that I found when checking backlinks. I'm not typically a fan of reddit, but this is a good list.

[^1]: Via [a minor tweak as packer-plugin-hyperv PR #33](https://github.com/hashicorp/packer-plugin-hyperv/pull/33) by [Daniel F. Dickinson (this author)](https://www.danielfdickinson.ca/)
