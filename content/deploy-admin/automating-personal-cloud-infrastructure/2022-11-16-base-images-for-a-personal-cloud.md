+++
slug = "base-images-for-a-personal-cloud"
aliases = [
	"/docs/deploy-admin/automating-personal-cloud-infrastructure/base-images-for-personal-cloud/"
]
author = "Daniel F. Dickinson"
date = "2022-11-16T14:37:55-0500"
publishDate = "2022-11-16T21:10:36-0500"
title = "Creating base VM images"
description = """\
On using Packer to create the base images Daniel uses for his personal 'cloud'
infrastructure.\
"""
summary = """\
On using Packer to create the base images Daniel uses for personal 'cloud'
infrastructure.\
"""
series = [
	"automating-a-personal-cloud-infrastructure"
]
tags = [
	"automation",
	"base-images",
	"cloud",
	"configuration",
	"debian",
	"docs",
	"hosting",
	"infrastructure",
	"linux",
	"self-host",
	"sysadmin-devops",
	"virtualization"
]
+++

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

Note that as of 2022-11-16 (November 16, 2022), this is still under development
and not yet used for a live deployment, although it is used for development
(local) deploys.

-------

## Preface

These are notes on using [Packer](https://www.packer.io/) to create the base
images Daniel uses for his personal 'cloud'[^1] infrastructure. The basic
philosophy for these base images is that they should be:

1. 'Golden' (that is they should be 'clean' images ready for provisioning with
the help of [cloud-init](https://cloudinit.readthedocs.io/en/20.4.1/)).
2. Relatively generic (i.e. they should contain those things which are common
to the instances to be deployed, but not instance-specific configuration or
packages).
3. Relatively small (this makes them easier to upload for use with the
applicable 'cloud' infrastructure).
4. Prefer 'systemd' networking and DNS resolution to the default Debian
'ifupdown' networking. (Mostly because ifupdown is showing it's age and is quite
a pain to work with).
5. The same base image should be usable in any of the different deployment
environments (development, staging/testing, and production) in which Daniel
will create instances.

In addition, because Daniel uses [Libvirt](https://www.libvirt.org) to host
his infrastructure, the images are prepared for that environment and are not
totally generic.

## Overview of the code repository

The repository contains the following basic elements:

1. The actual Packer 'code' (build definitions, variable definitions with
defaults, and supporting files).
2. CI[^2] using
[GitLab's 'pipelines'](https://docs.gitlab.com/ee/ci/pipelines/)
	1. Verifying basic commit checks have passed (using
		[pre-commit](https://pre-commit.com)), including file syntax, formatting,
		spell checking, and code style.
	2. Validation of the Packer configuration using `packer validate` CLI
		command.
	3. When a manual trigger is applied, running a test of the image building.
3. An [EditorConfig](https://editorconfig.org) file so that supported text/code
editors will make it easy to maintain the 'code style' for the repository.
4. Basic documentation of usage, acknowledgements, getting help, contributing to
the project, and copyright and licensing.

### Viewing the code

The code (less personalisation via private variables) for generating Daniel's
base images is available in a
[GitLab repository called 'DFD Debian VM images using Packer Qemu'](https://gitlab.com/danielfdickinson/debian-qemu-packer-dfd).

## Code Discussion

### Packer template (code) and supporting files

#### Build definition

* Consists mostly of variable definitions (below) to specify things like:
	* The amount of memory given to the virtual machine
	* The base hardware to emulate (currently qemu machine type `pc-q35-5.2`)
	* The target image name, format, compression, and output location
	* The image on which we base our image (an official debian 'cloud' image)

* Additionally specifies the parameters for communicating with the virtualised
system.
	* Expects the user running Packer to have `ssh-agent` active and have already
		added the SSH private key for the public key for the admin user (below)
	* Includes variables for how long to wait for SSH to respond and the ssh
		username (which is the default admin user for the image).

#### Cloud-Init definition

* This is where the bulk of the image customisation occurs.
* The `userdata` is the import part and defines the `cloud-init` modules to run,
	and their settings. Currently:
	* bootcmd (shell commands to run early): Set the default `etckeeper` git
		branch to `main`.
	* runcmd (shell commands to after write_files, near the end of `cloud-init`).
		See [variable settings (in the README for the code)](https://gitlab.com/danielfdickinson/debian-qemu-packer-dfd/-/blob/main/README.md#variables)
	* Make sure groups `adm`, `sudo`, 'and `sudonp` exist.
	* Increase the size of the 'root' (`/`) partition to expand to fill all empty
		space on the OS volume.
	* Upgrade and install packages (see [variable settings (in the README for the
		code)](https://gitlab.com/danielfdickinson/debian-qemu-packer-dfd/-/blob/main/README.md#variables)) for the package list.
	* SSH host key types to generate: Also see [variable settings (in the README
		for the code)](https://gitlab.com/danielfdickinson/debian-qemu-packer-dfd/-/blob/main/README.md#variables).
	* Create an admin user (member of the `adm`, `sudo`, and `sudonp` groups,
		which grants the user extra permissions and allows the use of `sudo`).
		Username, description, and SSH key (for image creation only) are defined
		in the variables.
	* Write files:
		* Configure members  `sudonp` group to be able use `sudo` without a
			password
		* Configure policy for unattended upgrade of packages and any needed
			reboot
		* Disable network configuration via `cloud-init` usual network
			configuration mechanism (it doesn't do what we want, at least with
			Debian 11 (Bullseye), which is what we use).
		* Set the default configuration for the first network interface to use
			`systemd-networkd` (ipv4 DHCP, no ipv6, no mDNS or LLMNR, and set the
			metric for the interface's default route so that if we have another
			interface we can easily set the second interface to be preferred or
			after the first network interface on a virtual system deployed using
			the base image we create).

#### Provisioning script

* Quite basic
	1. Wait for `cloud-init` to finish operation successfully (otherwise fails
		the build).
	2. Clean out the data used for the `cloud-init` run so that we get a pristine
		image.
	3. Tweak the networking setup to exclusively use `systemd-resolved` for DNS.
	4. Clean out the systems unique `machine-id` (since we're creating a base
		image to be used by machines that will need their own id).
	5. Clear out the SSH public keys used to communicate with the image.
	6. Ensure the image state is consistent (`sync` command).

### Variables (with their defaults)

* See [README](https://gitlab.com/danielfdickinson/debian-qemu-packer-dfd/-/blob/main/README.md#variables)

## CI Discussion

### When the CI tests are applied

### `pre-commit` checks

* On a push directly to the `doci` branch
* On a merge request _from_ any branch other than `doci`.

### Packer validation

* On a push directly to the `doci` branch
* On a merge request _from_ any branch other than `doci`.

### Packer build test

* On an action on the `doci` branch, but only if a manual trigger is applied
when the build test stage is reached.

[^1]: Using [Libvirt/KVM](https://www.libvirt.org) on
	[bare metal servers from OVH](https://www.ovhcloud.com/en-ca/bare-metal/).
	Daniel finds this more flexible and less expensive than using public cloud
	offerings.
[^2]: Continuous Integration (but not Continuous
	Delivery or Deployment). This means the code has to pass automatic tests to
	be applied to the GitLab repository, but that the infrastructure is not
	automatically updated on a merge to the 'main' branch.
