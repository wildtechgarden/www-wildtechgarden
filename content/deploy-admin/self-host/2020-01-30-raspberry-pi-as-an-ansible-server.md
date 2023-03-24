---
slug: raspberry-pi-as-an-ansible-server
aliases:
- /2020/01/30/raspberry-pi-as-an-ansible-server/
- /post/raspberry-pi-as-an-ansible-server/
- /deploy-admin/raspberry-pi-as-an-ansible-server/
- /raspberry-pi-as-an-ansible-server/
- /docs/sbc/raspberry-pi/raspberry-pi-as-an-ansible-server/
- /sysadmin-devops/self-host/raspberry-pi-as-an-ansible-server/
- /docs/deploy-admin/self-host/raspberry-pi-as-an-ansible-server/
author: Daniel F. Dickinson
date: '2020-01-30T13:38:00+00:00'
publishDate: '2020-01-30T13:38:00+00:00'
summary: For small deployments the Raspberry Pi makes a great choice for bare metal infrastructure for provisioning and configuration management servers.
description: For small deployments the Raspberry Pi makes a great choice for bare metal infrastructure for provisioning and configuration management servers.
tags:
- archived
- debian
- linux
- raspberry-pi
- self-host
- sysadmin-devops
title: "Raspberry Pi as an Ansible server"
---

{{< details-toc >}}

**Note**: This is not a tutorial on how to create and use Ansible playbooks.

## ARCHIVED

This article is now archived and may be out-of-date or inaccurate

## Why? Small footprint ideal for low demands

I use this as a bare metal provisioning and configuration server (using
Ansible) that has no dependencies on other hosts, for the case where I need to
bring up bare metal and virtual machine infrastructure (or recover from
failure). This is for tens of hosts not hundreds.

Since we are a talking about a low demand environment, the small size, low
electricity use, fanless operation, and low price of the Pi make it ideal.

In future articles I will detail using the same server to serve network booting and installs of CentOS, Debian, and Fedora and related projects (like Atomic), as well as allowing network boots of System Rescue CD. In addition the same server can easily act as the repository server for [package updates on an isolated network](2019-07-22-package-installation-and-updates-on-an-isolated-network.md).

A further use of this server is to act as a Debian [apt cache for isolated
networks](https://fabianlee.org/2018/02/11/ubuntu-a-centralized-apt-package-cache-using-apt-cacher-ng/).

With these capabilities all other servers on the network can be installed,
provisioned, and configured in an automated fashion.

## Set up the Pi

See the article on using a [Raspberry Pi as a server](2020-09-08-raspberry-pi-os-for-a-server.md)

## Documentation / learning Ansible

For the definitive reference see the [Ansible documentation](https://docs.ansible.com). Additionally, there are many tutorials and guides available online. Finally, there exist quite a number of books (digital or dead trees versions) on using Ansible that one can download and/or buy.

## Configure & use Ansible

### A few objectives

* No passwordless execution as root
* No passwordless SSH
* Ansible control user (ansible) will be a standard (no sudo permissions)
user that SSH’s to an ansible-client user on the host being provisioned or
configured, even for the ansible master (that is the ansible server itself).
* Use the Ansible Vault to avoid typing passwords aside from the Vault
password (and keeping secrets encrypted at rest (such as in a Git repo)).
* Codify the configuration of this server so that it could be configured
from another host, or rebuilt in an automated fashion using a backup of the
Ansible roles, playbooks, and vault.
* As much as possible keep roles generic (modified by variables) in order to
enable reuse of the roles.

### The end result

* The server (Raspberry Pi, which was initially configured following [Raspberry Pi OS as a server](2020-09-08-raspberry-pi-os-for-a-server.md) will have three users:
  * The users will have the passwords you define in the vault (see below).
  * The admin user
    * Remains on the system to perform administrative tasks not managed through Ansible (which should be unusual/avoided where possible).
    * Will have the SSH public key you provided (or the default SSH public of the user executing ansible-playbook) as the authorized\_keys files for public key SSH into the server as the admin user.
  * The ansible control user (Default: ansible)
    * The user with the ansible project(s) you use to manage your systems (including this server).
      * Will have the SSH public key you provided (or the default SSH public of the user executing ansible-playbook) as the authorized\_keys files for public key SSH into the server as the ansible control user.
      * Will use keychain to make sure the is one (and only one) ssh-agent instance available to the user.
  * The ansible client user (with sudo with password permissions): (Default: ansible-client)
    * Executes the tasks sent to it the ansible control user via ansible-playbook playbooks or ansible ad-hoc commands (sudoing to root of instructed via become).
* cli_users (Default: admin user and ansible control user) will have cp, rm, and mv aliased with  -i appended (meaning by default cp will prompt if a file already exists, rm will prompt to confirm removal, ,and mv will prompt if a file already exists, when these commands are run interactively from the command line.
* termulti_users (Default: cli_users) will have a configuration for the program selected by termulti_choice (see below).
  * For SSH sessions and the like (i.e. any terminal besides a terminal on a physical monitor and keyboard or serial console) the termulti_choice program will be launched on login.
* The following additional packages will be installed (combined list):
  * aptitude
  * rsync
  * iotop
  * ansible
  * ansible-lint
  * keychain
  * git-core
  * git-doc
  * git-email
  * patch
  * quilt
  * The ‘default_editor’ configured in vars.yml (see below)
  * The ‘termulti_choice’ configured in vars.yml (see below)
    * ‘termulti’ packages that are not needed by termulti_choice will be removed.
* The ANSIBLE_CONFIG variable will be defined for the ansible user
* The file ~/.ansible.cfg will exist and will be the default ansible configuration (via ANSIBLE_CONFIG).
* The ansible config will define /var/log/ansible/ansible.log as the ansible log file (for ansible or ansible-playbook commands run by the ansible control user), and /var/log/ansible will be have rwx permissions for the ansible control user and rx permissions for the adm group (of which the admin user will be a member, so the admin user will be able to read the ansible logs). Also ansible facts will be cached in memory.
  * ansible logs will have log rotation enabled
* Ansible fact gathering will be disabled by default as will as injecting facts as top-level variables.
  * This means that one ansible task needs gatherFacts: true and any subsequent tasks will be able to use the gathered facts.
  * Facts will only be accessible via the ansible\_facts top-level variable. (e.g. ansible_facts['architecture'] will give you the architecture of the ansible client machine but ansible\_architecture will not be defined by the fact gathering.

#### default_editor

default_editor and default_editor_path (both must be set) are used to
set the system-wide default command line editor. The default is nano. If
vim-nox is chosen as the default editor then users in cli_editor_users
list will get the .vimrc included in the cli_editor role.

#### termulti_choice

termulti_choice selects which terminal multiplexor (if any) is configured
for users in the termulti_users list.

A terminal multiplexor is a why of having multiple console sessions within a
single login (e.g. if one uses SSH and has a multiplexor enable on login, then
one can open new interactive sessions without using another SSH session).

Currently the choices are:

* byobu : default on resources_normal systems
* tmux : default on resources_low systems
* screen: another option
* none : don’t use a terminal multiplexor

### Option 1: From Pi console

#### Initial configuration

##### Preliminaries

* For this option we will bootstrap with a keyboard and monitor attached to
the Pi; if you have a host capable running Ansible you could provision the
Pi from that host (see option 2). You might want to use that option in
order to bootstrap the server from a laptop, before making this server
the provisioning and configuration master.
* I further assume you have a Pi configured using the article on using
a [Raspberry Pi OS as a Server](2020-09-08-raspberry-pi-os-for-a-server.md).

##### Create the Ansible control user

1. Login is as user the default user for the image you created or downloaded.
2. If you are using an external drive mounted on /var (as I am) you
probably want to use a location such as /var/local/ansible as your
ansible control user’s home. In other cases the standard home directory
(/home/ansible) can be a more convenient choice. If you are using an
external /var:
   1. sudo addgroup --gid 2000 ansible
   2. sudo adduser --home /var/local/ansible --uid 2000 --gid 2000 ansible
   3. Otherwise (using standard home directory):
   4. sudo addgroup --gid 2000 ansible
   5. sudo adduser --uid 2000 --gid 2000 ansible
   6. for group in adm staff operator gpio spi i2c; do sudo adduser ansible $group; done

##### Create the Ansible client user for this host

1. sudo addgroup --gid 1999 ansible-client
2. sudo adduser --uid 1999 --gid 1999 ansible-client
3. sudo adduser ansible-client sudo (allows ansible-client to become root).
4. for group in adm staff gpio spi i2c; do sudo adduser ansible-client $group; done
5. exit

##### Create a public/private keypair for control user

1. Login as the ansible user.
2. Create an SSH public/private key pair for the ansible user: (I use ed25519 key type because it is the only type of key compatible with all my systems).
   1. mkdir .ssh
   2. chmod 700 .ssh
   3. ssh-keygen -t ed25519
   4. You should now have ~/.ssh/id\_ed25519 and ~/.ssh/id\_ed25519.pub

##### Copy the control user public key to the client’s authorized keys

1. cp ~/.ssh/id_ed25519.pub /tmp/
2. Switch to another virtual terminal (press ‘Ctrl-Alt-F2’) and login as the ansible-client user.
3. mkdir .ssh
4. chmod 700 .ssh
5. cp /tmp/id_ed25519.pub ~/.ssh/authorized\_keys
6. chmod 600 ~/.ssh/authorized\_keys

##### Install Ansible & Git

1. sudo apt update
2. sudo apt upgrade
3. sudo apt install ansible git

#### Obtain sample Ansible project

1. Exit the ansible-client login (exit).
2. Switch back to the ansible user (press ‘Ctrl-Alt-F1’)
3. git clone <https://github.com/danielfdickinson/ansible-sample-for-rpi-article> ansible

#### Modify sample project for your environment

1. cd ansible (change to project directory)

2. Modify variables under group_vars and host_vars to suit your
needs. For example, if you changed the default user name for the SD card
image, you would want to change the value of admin_user_name in the file
group_vars/all/vars.yml to your username. Using george as an
example:
   * You would change

   ```yaml
   ansible_user: 'ansible-client'
   admin_user_name: 'pi'
   admin_user_comment: 'Admin'
   admin_gid: 1000
   admin_uid: 1000
   default_editor: nano
   default_editor_path: /usr/bin/nano
   ansible_client_user_name: 'ansible-client'
   ansible_client_user_comment: 'Ansible Client User'
   ansible_client_gid: 1999
   ansible_client_uid: 1999
   ansible_client_groups:
    - adm
    - staff
    - sudo

   shrc_type: bashrc

   termulti_choice: tmux
   termulti_packages:
    - tmux
   cli_editor_users: '{{ cli_users }}'
   keychain_users: '{{ cli_users }}'
   safefile_users: '{{ cli_users }}'
   termulti_users: '{{ cli_users }}'
   sh_users: '{{ cli_users }}'

   cli_users:
    - pi

   ansible_user: 'ansible-client'
   admin_user_name: 'george'
   admin_user_comment: 'Admin'
   admin_gid: 1000
   admin_uid: 1000
   default_editor: nano
   default_editor_path: /usr/bin/nano
   ansible_client_user_name: 'ansible-client'
   ansible_client_user_comment: 'Ansible Client User'
   ansible_client_gid: 1999
   ansible_client_uid: 1999
   ansible_client_groups:
    - adm
    - staff
    - sudo

   shrc_type: bashrc

   termulti_choice: tmux
   termulti_packages:
    - tmux
   cli_editor_users: '{{ cli_users }}'
   keychain_users: '{{ cli_users }}'
   safefile_users: '{{ cli_users }}'
   termulti_users: '{{ cli_users }}'
   sh_users: '{{ cli_users }}'

   cli_users:
     - pi
   ```

    * Note the file format for the variables files is YAML. You can view a
    detailed [definition of the YAML format](https://yaml.org/spec/1.1/#id857168) so that you know what how the files need to be formatted.
3. You will definitely want to change the name of the directory
hosts_vars/raspshorian.example.com to the fully qualified domain name
of your server on your network.
    1. hostname -s will give your the first part of the fully qualified domain name. We don’t used hostname --fqdn to get the fully qualified domain name (FQDN) because, per the man page, it is unreliable.
    2. cat /etc/resolv.conf. You should see something like:

       ```conf
       nameserver 192.168.1.1
       search lan
       ```

    3. Use .\<name-after-domain-or-search> as the last part of the FQDN (e.g. for hostname -s giving john use john.lan). If you see domain \<name-with-or-without-dots> prefer that to what is after search. Otherwise use the part after the first search keyword in /etc/resolv.conf. For example if hostname -s gave charles then you would want to rename host_vars/raspshorian.example.com to host_vars/charles.lan if you had the above resolv.conf.
    4. Verify your FQDN can be found by doing ping -c 4 \<fqdn>. In the above example ping -c 4 charles.lan should report 100% success after four pings.

* Some files and variables you will probably want to change are:
    | File                        | Variable                  | Description                                                                                                                              |
    | --------------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
    | group_vars/all.yml          | admin_user_name           | The admin user created when creating the SD card images                                                                                  |
    | group_vars/all.yml          | cli_users                 | Users who use the command line (you probably want to chang rcshore to your admin user)                                                   |
    | hosts_vars/\<fqdn>/vars.yml | ansible_control_user_home | The home directory of the ansible user. You will want to change this to /var/local/ansible if using an external /var as described above. |
* You will also need to copy the public key you use to access the admin user
to roles/common_pre/files/public_keys/admin_user.
* You should also copy the public key you want to use to access the ansible
control user (ansible) to
roles/ansible_control/files/public_keys/ansible_control_user.
* Because you have already created the ansible client user you also need to
place the SSH public key that the ansible control user uses to access the
ansible client user in ``roles/common_users/files/public_keys/ansible_client_user``. E.g.
``cp ~/.ssh/id_ed25519.pub roles/common_users/files/public_keys/ansible_client_user`` (assuming you are in the ansible directory created by the git clone above).
* Of course you can explore and see what else you want to change, but if
you’re just getting started it’s probably best to make only the necessary
changes and get a feel for how things work first.

##### Setup your Vault

host_vars/raspshorian.example.com/vault (where raspshorian.example.com
is your fully qualified hostname as described above) is a special file. It is
encrypted in order to be a safe place to store ‘secrets’ like passwords even if
you keep your ansible project in version control (although it is still not
recommended to use public repositories including a real vault). [Ansible
Playbook Best Practices: Variables and Vaults](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_best_practices.html#variables-and-vaults)
explains how and why to separate ‘secrets’ into protected vaults.

1. cd host_vars/raspshorian.example.com (substituting the name you gave
the directory, which should be the hostname of your server)
2. ansible-vault decrypt vault The password for the example vault is
GnWcAWkiyuH8PmGPw9h8FiNTBSKw4aCJh9EddBRg.
3. Edit the variables in the vault to suit your needs (see below).
4. Create your own private vault: ansible-vault encrypt vault and use a
strong password of your choice. Make sure you do not lose this password as
it is now the only way to access the contents of the vault.
5. In future, when you want to edit the vault use ansible-vault edit vault
instead of ansible-vault decrypt vault. That way the vault will be
automatically encrypted with the same password as before when you exit your
editor.

##### Variables to edit in the sample Vault

For this example project these vault variables are specific to the host matching the hostname of the directory it is in (e.g. george.lan in the example above).

| Variable                             | Description                                                                                                                                                                                                                                                                                                                                                                        |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| vault_ansible_become_pass            | plaintext password for the user used as the ansible client (by default, after using the sample project, the user is the ‘ansible-client’ user). Note that if the password contains special characters you will need to enclose it in double quotes (") and use [YAML escaping](https://yaml.org/spec/1.1/#id904245).                                 |
| vault_admin_use_password             | Password hash of password of the default user for the image (i.e. by default the hash of the password for the ‘rcshore’ user). You need to [generate a password hash from a password](https://docs.ansible.com/ansible/2.7/reference_appendices/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module). I recommend using the mkpasswd option from the Pi command line. |
| vault_ansible_control_user_password  | Password hash of password for the ansible control user (user ansible in this article). See above for how to generate the hash                                                                                                                                                                                                                                                      |
| vault_ansible_control_ssh_passphrase | Plaintext password for the ssh key for the Ansible control user (user ansible in this article). You should use the password you entered when you created the ssh key for the ansible user, above.                                                                                                                                                                                  |
| vault_ansible_client_user_password   | Password hash of the password for the ansible client user (see above for creating the hash).                                                                                                                                                                                                                                                                                       |

#### Configure the inventory

In hosts-staging.yml replace all instances of raspshorian.example.com
with the DNS name or IP address of your server. If using a DNS name it must
correctly resolve to your server’s IP address.

#### Apply the project

Once you have customized the project appropriately for your system, you can
use it by executing ansible-playbook -i hosts-staging.yml --ask-vault-pass playbook-site.yml.

### Option 2: From another host

#### Initial configuration for Ansible from another host

##### Preliminaries for remote Ansible

* These instructions presume that you can access the target Pi via a DNS name that is the same as its FQDN. (See step three (3) in [“Modify Sample Project for Your Environment”](#modify-sample-project-for-your-environment), above).
* These instructions also assume you can access the target Pi via SSH to the default user (Default: rcshore).
* The instructions further assume you have a Pi configured using the article on [using a Raspberry Pi OS as a Server](2020-09-08-raspberry-pi-os-for-a-server.md).

##### Copy your public key to admin user on the Pi

You need to make sure a public key used by the user you plan on using to
provision the Pi for the other (controlling) host is in
~/.ssh/authorized\_keys for the admin user on the Pi, and that the .ssh
directory is mode 0700 and authorized_keys in that directory is mode 0600.

#### Follow the steps below from Option 1

1. [Install Ansible & Git](#install-ansible--git) on the provisioning host.
2. [Obtain Sample Ansible Project](#obtain-sample-ansible-project) on the provisioning host.
3. [Modify Sample Project for Your Environment](#modify-sample-project-for-your-environment) with the following differences:
   1. If you don’t add the admin_user public key (step 5), the playbook will use ~/.ssh/id_ed25519 or ~/.ssh/id_rsa (in that order) from the user doing the provisioning (on the provisioning host).
   2. Likewise the ansible control user’s public key (step 6).
   3. You can omit Step 7.
4. [Setup Your Vault](#setup-your-vault) with the following difference:
   * While provisioning vault_ansible_become_pass should be the plaintext admin user password. Once you are using ansible on Pi you will need to switch this to the ansible client user password.
5. [Configure the Inventory](#configure-the-inventory).
6. [Apply the Project](#apply-the-project)
