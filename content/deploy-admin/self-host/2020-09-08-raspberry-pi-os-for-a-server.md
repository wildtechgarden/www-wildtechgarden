---
slug: raspberry-pi-os-for-a-server
aliases:
- /2020/09/08/raspberry-pi-os-for-a-server/
- /post/raspberry-pi-os-for-a-server/
- /deploy-admin/raspberry-pi-os-for-a-server/
- /raspberry-pi-os-for-a-server/
- /2020/01/18/raspberry-pi-serverr/
- /2020/01/18/raspberry-pi-server/
- /post/raspberry-pi-server/
- /raspberry-pi-server/
- /docs/sbc/raspberry-pi/raspberry-pi-os-for-a-server/
- /sysadmin-devops/self-host/raspberry-pi-os-for-a-server/
- /rpi-server/
- /post/rpi-server/
- /docs/deploy-admin/self-host/raspberry-pi-os-for-a-server/
author: Daniel F. Dickinson
date: 2020-09-08T04:26:00+00:00
publishDate: 2020-09-08T04:26:00+00:00
tags:
- linux
- raspberry-pi
- self-host
- sysadmin-devops
title: Raspberry Pi OS as a server
summary: "You may find yourself in need of a 'bare metal' server. If the workload is not too demanding, a Raspberry Pi can be a good choice."
description: "You may find yourself in need of a 'bare metal' server. If the workload is not too demanding, a Raspberry Pi can be a good choice."
---

{{< details-toc >}}

## Preface

For small deployments (or home or small office use) you may find yourself in need of a 'bare metal' server, but not want or need the expense of an x64 machine. If the workload is not too demanding, a Raspberry Pi can be a good choice. The Pi has the benefit of being inexpensive, using little electricity and taking minimal space.

{{< figure alt="Raspberry Pi 2 in an official strawberry red and white case in the palm of a human hand, with top cover removed and Pi 2 circuit board showing" caption="Raspberry Pi 2 in an official strawberry red and white case in the palm of a human hand, with top cover removed and Pi 2 circuit board showing" src="/assets/images/PiBoardOfficialCase.jpg" class="three-quarter-width">}}

### Hardware / Base OS

For testing and experimentation for this article a Model B+ and a Pi 2 have been used, but any model should work.  With a Pi 2 may want to investigate using Ubuntu Server (32-bit), and for a Pi 3 or higher an 'aarch64' Linux (such as Ubuntu Server aarch64). 'aarch64' is the 64-bit version of Linux for ARM processors and is often a better choice (and certainly is for models with large amounts of RAM).

#### Not using wireless

While we could use wireless, servers used for basic infrastructure benefit from the stability and reliability of a wired connection. In addition, on models of Pi available to the author wireless is an addon rather than builtin.

### Why? (Some low demand server use cases)

In the past the author has used this as a bare metal provisioning and configuration server (using Ansible) that has no dependencies on other hosts, for the case where there is a need to bring up bare metal and virtual machine infrastructure (or recover from failure). A similar configuration has been used to serve network booting and installs of CentOS, Debian, and Fedora and related projects (like Atomic), as well as allowing network boots of System Rescue CD. In addition, the same server can easily act as the repository server for [package updates on an isolated network](2019-07-22-package-installation-and-updates-on-an-isolated-network.md). A further use of this server is to act as a Debian [apt cache for isolated networks](https://fabianlee.org/2018/02/11/ubuntu-a-centralized-apt-package-cache-using-apt-cacher-ng/). With these capabilities all other servers on the network can be installed, provisioned, and configured from this server.

Since this is a low demand environment, the small size, minimal electricity use, fanless operation and low price of the Pi make it ideal.

This time around the Pi is being used to host a small PostgreSQL instance, due to lack of an available virtual machine host on the local network (*Authors Note*: remind me not to use water-cooled heatsinks; not because of short circuits when they leak, but that with a very slow leak, they result in the CPU overheating and the CPU and/or motherboard being damaged without it being noticed until too late).

### A note on using swap and /var on an external drive

This article discusses techniques for using swap and /var on an external drive as there are times this can be useful. In particular if one has an external spinning disk or other external media which is faster and has more write cycles than an SD card, then it can make sense to move both swap and the /var directory (and maybe /tmp) to the external drive(s). This is because it will increase the speed and robustness of the system due to the fact swap and /var (and often /tmp) are written frequently. In addition, the faster swap is, the better, although you still want to avoid situations where you exceed available memory and end up where swap is thrashing and bringing the system to a crawl. (External drives help because the SD and microSD cards on which the Pi OS typically resides is almost certainly slower than any external drive).

## If you need this frequently, automate

It is assumed you aren't planning on doing this often as, if you are, you really ought to automate your process.

* For Pi OS there is <https://github.com/RPi-Distro/pi-gen> and derivatives
* Alternatively, for a more 'stock' Debian, there is: <https://github.com/drtyhlpr/rpi23-gen-image>
* For Ubuntu Server 20.04, you can use cloud-init (it's included) and the tools like Ansible, Puppet, Chef or Salt Stack. See <https://ubuntu.com/server/docs/install/autoinstall>, which also applies to Pi 2+ preinstalled images.

## Obtain base image for RPi SD card

**NB**: Raspberry Pi OS has very recently (as I tweak this page in early November 2021) switched to being based on Debian 'Bullseye' instead of 'Buster' so there are some minor changes and tweaks noted on this page to reflect that.

### The easy way

1. Follow the instructions on the [Raspberry Pi Foundation download page](https://www.raspberrypi.com/software/) to get the Raspberry Pi Imager for your operating system.
2. Launching the imager will give you the option to select an image to download. For a Model B+ you want to select ‘Raspberry Pi OS (Other)’ and the ‘Raspberry Pi OS (32-bit) Lite’.
3. You then select your SD card.
4. Select write, and the imager will write and verify the image.
   1. If the verification fails this could mean a bad SD/microSD card.
   2. It could also mean a bad writer device.
   3. If you have both a microSD card writer and a full SD card writer, then if you used the microSD card writer, it can help to put the microSD card into an adapter that allows you to use the microSD card in the SD card writer, and try the full-sized SD card writer instead. Conversely if you used the adapter, it can help to use a plain microSD card slot.
   4. Upshot is that SD card/micro SD card devices are not terribly reliable, and similarly the cards. If none of the combinations you have available verify, you may need to invest in a new microSD card and/or a new microSD card writer device.

### In case of slow download speeds or you want a copy of the image

A [Raspberry Pi OS (32-bit) lite](https://downloads.raspberrypi.org/raspios_lite_armhf_latest) image provides a solid base for this configuration.

If you find download speeds are slow you may wish to try the
[Raspberry Pi OS (32-bit) lite torrent](https://downloads.raspberrypi.org/raspios_lite_armhf_latest.torrent).

1. You still want the ‘Raspberry Pi Imager’.
2. Launch the imager and select ‘Use custom’ (which is the last item on the list of choices when you select ‘Choose OS’)
3. Select the ZIP file you downloaded above (either via HTTPS or Torrent).
4. You then select your SD card
5. Select write, and the imager will write and verify the image.

### Configure for headless operation

Basically: put an empty file called 'ssh' on the 'boot' partition of the SD card (not boot directory in the root partition).

See:

* <https://howtoraspberrypi.com/how-to-raspberry-pi-headless-setup/>
* <https://pimylifeup.com/headless-raspberry-pi-setup/>

## Boot the Pi and perform initial configuration

### Boot the Pi for the first time (with this image)

1. Boot the Pi.
   * The root partition will be resized and the Pi will reboot.
2. Once the SD card light stops flashing and is off for at least a minute, you should be able to login via SSH[^1].
3. See the links above to see how to determine the address of your Raspberry Pi so you can login.

### Initial configuration

1. Login (username: pi, password: raspberry): ``ssh pi@<address-of-your-pi>``
2. ``passwd`` — Enter your old password, and then a better (and unique) password for your pi (twice), following the prompts. Remember it!
3. ``sudo apt update && sudo apt upgrade -y``
4. ``sudo shutdown -r now``
5. Once the Pi reboots, login again.
6. Use the Raspberry Pi configuration tool: ``sudo raspi-config``
   1. Select 5 Localisation Options
      1. Select L1 Locale
      2. Choose the locales you want and accept them, then wait.
   2. Select 1 System Options
      1. Select S4 Hostname
      2. Enter a new hostname for the Pi when prompted
   3. Select 5 Localisation Options again
      1. Select L2 Change Time Zone
      2. Select your time zone (note that Canadian cities are under ‘America’, for the continent, rather than the country)
   4. Select 4 Performance Options
      1. Select P2 GPU Memory
      2. Enter ``16`` and press ENTER — this frees up some memory that would be dedicated to the GPU (graphics) (default is 64)
   5. Select Finish
      1. Select 'Yes' for 'Would you like to reboot now?'
7. The Pi will reboot and you should login again.

### Configure public key for SSH logins — recommended

* Public Key authentication is much more secure than password based (provided you have a password on your private key, which is the default), so configure and only allow public key logins via SSH going forward
   1. On your workstation (not the Pi server) create a SSH keypair (or keypairs) if you don’t already have one. See one of the many guides on the internet if you need more information, for example:
       * [GitHub’s Guide for SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
       * ~~[Oracle’s Guide for SSH]\(``https://docs.oracle.com/en/cloud/paas/database-dbaas-cloud/csdbi/generate-ssh-key-pair.html#GUID-4285B8CF-A228-4B89-9552-FE6446B5A673``)~~
       * [Scaleway’s Guide for SSH Key Generation](https://www.scaleway.com/en/docs/console/my-project/how-to/create-ssh-key/)
       * [OVH Guide for SSH Key Generation](https://docs.ovh.com/gb/en/public-cloud/public-cloud-first-steps/#step-1-creating-ssh-keys)
   2. On the Pi, as your admin user
      1. ``mkdir .ssh``
      2. ``chmod 700 .``
      3. ``chmod 700 .ssh``
      4. ``cd .ssh``
      5. ``touch authorized_keys``
      6. ``chmod 0600 authorized_keys``
      7. ``sensible-editor authorized_keys``
         1. Paste in your SSH public key
         2. Save and exit the editor
   3. In another terminal on your workstation, ssh in to your admin user; you should be able login with key instead of the password for the user (you may be prompted for the password for the key; to minimize that read up on ``ssh-agent``)
   4. In the origin session, 'exit'
   5. ``sudoedit /etc/ssh/sshd_config``
   6. Add a line:
      * ``PasswordAuthentication no``
   7. Make sure there are no uncommented ``PasswordAuthentication yes`` lines
   8. Add a line
      * ``PermitRootLogin no``
   9. Make sure there are no other uncommented lines with ``PermitRootLogin`` and values other than ``no``
   10. ``sudo sh -c 'sshd -t -f /etc/ssh/sshd_config; echo $?'`` — 0 should be emitted and there should be no error messages
       * Fix errors if necessary before proceeding to the next step
   11. ``sudo systemctl restart sshd``
   12. In another terminal  on your workstation ssh to the admin user to verify all is still well

#### Author: A personal preference for the admin user

* I prefer to replace the default user ``pi`` with a different administrative user
  * Having admin user home under ``/local-home`` instead of ``/home`` means that if there are users under ``/home`` with large dirs, that the dirs can be mounted on a separate drive/partition. It also facilitates shrinking the size of ``/home`` (easier to avoid ``/home`` being in use, which matters because in order to shrink a filesystem you need to unmount it), should you wish to reallocate the storage for another purpose.
  * If admin user is a member of group sudo they can have full root access but a password will be required instead of the default configuration for the ``pi`` user, which is full root without entering the user's password again.
* The commands:
  1. ``sudo adduser --home /local-home/newadmin --shell /bin/bash --gecos "New Admin User,,," newadmin``
  2. ``sudo adduser newadmin sudo``
  3. ``sudo adduser newadmin adm``
  4. ``sudo adduser newadmin staff``
     * Note that the default ``pi`` user is a member of a number other groups which are more relevant for desktop use, or accessing the Pi's electronics capabilities; is you need any of that you should add ``newadmin`` to the those groups as well.
  5. ``sudo cp -r .ssh /local-home/newadmin/`` — This assumes you want to use the same SSH keypair for the newadmin as you are now using for the ``pi`` user; you could instead follow the instructions above for the ``newadmin`` user (to act as the ``newadmin`` user without a new login, use: ``sudo su - newadmin``).
  6. ``sudo chown -R newadmin:newadmin /local-home/newadmin/.ssh``
  7. ``sudo chmod 700 /local-home/newadmin``
  8. From your workstation login as ``newadmin`` (e.g. ``ssh newadmin@<address-of-your-pi>``)
  9. Once you are logged in as the ``newadmin`` user, verify you can sudo (e.g. ``sudo ls -al /home/pi/.ssh`` for which you should see ``pi``'s authorized_key file with additional info)
  10. Logout of all sessions in which are are logged in as ``pi``
  11. (Personal preference) Remove the old admin user (``pi``) by issuing: ``sudo deluser --remove-home pi``. If you don't do this, you should at least make sure the ``pi`` user and ``newadmin`` user are using different passwords and SSH keypairs. Removing the ``pi`` user has the advantage that script-based attacks spam you less, especially if you also change the SSH port, which makes it easier to examine your logs for untoward behaviour.

## Install packages required to complete configuration

* (Optional) If you are planning on using external storage, the ``lvm2`` and ``smartmontools`` ~~and ``mutt``~~ *(no longer required for Bullseye)* packages are recommended. ``lvm2`` is the only method described in this article for setting up the storage. ~~(The ``mutt`` package allows you to read the local email messages created by ``smartmontools`` default configuration).~~ *(as of Bullseye smartmontools no longer sends mail by default)*
* For the configuration described, ``ufw`` is required.
* On a Pi Model B+ I do not recommend ``cryptsetup`` or full disk encryption as it does not have the horsepower nor crypto offload. One should therefore make sure that any sensitive data one stores on the Pi is encrypted at the application level (rather than at the OS level as is the case with full disk encryption).

### Installing the above packages (optional)

1. Execute ``sudo apt install -y lvm2 smartmontools ufw`` (add ``mutt`` to that list if pre-Bullseye)
2. Configure ``/etc/aliases`` to send local mail messages[^2] to your admin user (e.g. ``newadmin``)
   1. ``sudoedit /etc/aliases``
   2. Add a line ``root: newadmin`` (obviously substituting the name of your admin user for ``newadmin``)
   3. ``sudo newaliases``

### Author preferences For admin tools

* *aptitude* (optional; an easier way to browse packages on the command line)
* *byobu* (optional but very useful tool for managing your interactive sessions)
* *etckeeper* (keeps /etc under local version control)
* *dnsutils* (tools for troubleshooting DNS)
* *fail2ban* (optional on a local server; highly recommended on a public server)
* *iftop* (Monitor connections (most used, total bandwidth) on an interface, in a 'top-like' format)
* *iotop-c* (Monitor I/O performance in a 'top-like' format) *(Pre-Bullseye has iotop instead of the choice of iotop-c)*
* *unattended-upgrades* (optional but useful for keeping packages up to date, automatically)
* *ufw* (firewall;  recommended)
* *whois* (optional but handy tool for checking owners of public IP addresses contacting your server - also pulls in handy DNS utilities; includes mkpasswd tool)

Execute ``sudo apt install -y aptitude byobu etckeeper fail2ban iftop iotop-c unattended-upgrades ufw whois``

If you want to start using ``byobu`` immediately, execute ``byobu``. This has certain advantages if you become disconnected, or need to open another terminal session, and you know how to use it.

## Using swap and /var (and more) on an external drive (optional)

### Prepare the drive

If you only have one USB storage device attached to the Pi, this is easy; it is known as ``/dev/sda``. For the purposes of this guide we will assume this is the situation.

1. To verify the device is turned on and recognized by the Pi, do: ``sudo dmesg|grep sda``
   * You should see messages showing the correct device's information.
2. If the device is S.M.A.R.T. capable ``sudo smartctl -i /dev/sda`` should correctly identify the device and show some information about it (assuming you installed ``smartmontools`` as described above).
3. To partition (initialize) the device, execute ``sudo parted /dev/sda``
4. Unless you have a specific need for an ``msdos`` partition, I recommend using ``mklabel gpt``
5. Then, ``mkpart primary 1 -1``
6. ``quit``
7. ``sudo pvcreate /dev/sda1`` — Prepares the drive for use as a 'physical volume' by LVM2
8. ``sudo vgcreate vg1 /dev/sda1`` — Creates a volume group on physical volume /dev/sda1 (a volume group can span multiple physical volumes) for LVM2
9. ``sudo pvs`` will show you the physical volume status
10. ``sudo vgs`` will show the volume group status

### Using swap on an external drive

1. Create a 'logical volume' for your swap partition that is about the same size as your RAM (e.g. for a Pi Model B+ about 512 MiB): ``sudo lvcreate -L 512M -n swap vg1``
   * There is much conflicting advice about how big a swap partition should be. It's fairly application and hardware dependent, but in general you only want swap available when apps / os aren't going to try to use it like primary RAM (because swap is much slower than RAM). Swap is effective when it allows memory-resident but inactive programs / data to be swapped out to disk so that there is more immediately available RAM for active applications.
2. Next execute ``sudo mkswap /dev/vg1/swap``
3. Execute ``sudoedit /etc/fstab``
   1. Add a line like ``/dev/vg1/swap none swap sw 0 0``
   2. Save and exit
   3. Execute ``sudo swapon -a``
   4. Execute ``sudo dmesg`` and verify that there haven’t been any errors using the swap partition.
   5. Execute ``cat /proc/swaps`` — you should see see your new swap partition (you will likely also see a ``/var/swap`` 'file' — we'll remove that next)
4. sudo ``sudo systemctl stop dphys-swapfile``
5. sudo ``sudo systemctl disable dphys-swapfile``
6. sudo ``sudo rm -i /var/swap``
7. sudo ``sudo apt remove -y --purge dphys-swapfile``

### /var on an external drive

1. This is much easier with rsync, so execute ``sudo apt install rsync``.
2. Create a 'logical volume' for your ``var`` partition that fits your storage and you think is big enough. If you will be using volumes for more than just ``/var``, you should create your volumes so that there is space left unallocated in the volume group. That allows you to increase the size of a volume that turns out not to have have storage 'on-the-fly' (you'll need to look for guides on using ``lvresize`` and ``resize2fs`` to see how to achieve that; that is beyond the scope of this article). For example, ``sudo lvcreate -L 20G -n var vg1``.
3. Format the partition:
    1. Option 1: Default: Faster initially but creates a background task to 'lazy init' the partition: ``sudo mkfs.ext4 /dev/vg1/var``
    2. Option 2: Turn off lazy init: ``sudo mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/vg1/var``
4. Before you can add the new partition to fstab you need to move /var.
    1. Execute the following commands:

        ```sh
        sudo -sH
        mount /dev/vg1/var /mnt
        systemctl stop syslog.socket rsyslog
        systemctl stop systemd-journal*.socket systemd-journal*.service
        rsync -arHAXx --info=progress2 /var/ /mnt/
        umount /mnt
        mv /var /var.old
        mkdir /var
        mount /dev/vg1/var /var
        sudoedit /etc/fstab
        ```

    2. Add a line such as ``/dev/vg1/var /var ext4 defaults,relatime 1 1``
    3. Save and exit
    4. Execute ``sudo mount -a``. If it doesn't succeed, you need to fix the problem else your system will not boot.
    5. Reboot
    6. If you’ve done things right, ``df -h`` should show your new partition (possibly as ``/dev/mapper/vg1-var``) mounted on ``/var``.
    7. Execute ``sudo rm -rf /var.old``

### /tmp on an external drive

If you wish you can repeat for ``/tmp`` (with appropriate substitions)

### Other mountpoints on an external drive

Ideally for other mountpoints you create the logical volume and mount it (entry in ``/etc/fstab`` then ``sudo mount -a``) before you use the partition so that you don't need to copy the old contents and owner/permissions to the new destination.

## Recommended and suggested configurations

### Configure the firewall (Recommended)

* ``ip addr show``
  * You should see that ``eth0`` has an ip address. If not, you need to use a different (not ``eth0``) interface, which will involve learning more about Linux/Debian networking.
* ``sudo ufw allow in on eth0 from any to any app OpenSSH``
  * (note that eth0 is the default for Ubuntu Pi 2 and Pi OS on any Pi with hardware ethernet; other OS / hardware will need a different interface; for example typical Ubuntu and Debian cloud images will give ``ens3`` as the interface you need to deal with)
* ``sudo ufw enable`` — **NB** Make sure you have the right interface above else you will be locked out from network access to the Pi and will either need to attach a keyboard and monitor and fix things, or reinstall.

### (Optional) Enable Byobu system-wide

* I suggest using Byobu for all users who login to a shell, which is easily enabled by executing: ``sudo touch /etc/byobu/autolaunch``.  From now on, when you login to a shell (e.g. via SSH) byobu will launch.
* For each user, I recommend they ``touch .byobu/.always-select``. This will cause byobu to prompt to create a new session or login to an existing one, when a user logins and already has a running byobu session.
* I also recommend each user execute ``byobu-config`` and choose the items they want to have appear on their status bar in byobu.

### Configure fail2ban

#### Suggested locally; recommended for public-facing systems

Note that we comment out the enabling of nginx fail2ban jails until after we install nginx (if we do).

Place the following in ``/etc/fail2ban/jail.local`` and executed ``sudo systemctl restart fail2ban``.

```ini
[DEFAULT]

# "ignoreip" can be a list of IP addresses, CIDR masks or DNS hosts. Fail2ban
# will not ban a host which matches an address in this list. Several addresses
# can be defined using space (and/or comma) separator.
ignoreip = 127.0.0.1/8 ::1

[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
#mode   = normal
enabled = true

[nginx-http-auth]
#enabled = true

[nginx-botsearch]
#enabled = true

# Ban attackers that try to use PHP's URL-fopen() functionality
# through GET/POST variables. - Experimental, with more than a year
# of usage in production environments.

[php-url-fopen]
#enabled = true
```

### Configure unattended-upgrades (recommended)

* ``sudoedit /etc/apt/apt.conf.d/50unattended-upgrades``
  * Configure as appropriate for your situation (the defaults are safe, but you might want automatic reboots at a specific time, if necessary)
  * For Pi OS replace ``origin=Debian`` with ``origin=Raspbian`` and ``label=Debian`` with ``label=Raspbian``
  * Add '``"origin=Raspberry Pi Foundation,codename=${distro_codename},label=Raspberry Pi Foundation";``' in the ``Unattended-Upgrade::Origins-Pattern`` section

## Install and configure backups (recommended)

For this article we will use ``restic`` because it allows backing up to a variety of remote storage types.

* It is recommended to minimize how much of the backing up is done while 'root'. Therefore, where possible, one should use the restic command as the user that 'owns' the data.
* While the description below is for data requiring root access or the [appropriate capability](https://restic.readthedocs.io/en/stable/080_examples.html#full-backup-without-root), we don't use the capability option here because the capability setting will be lost if ``apt`` updates the binary (e.g. due to bug fix).
* It is recommended to not use environment variables for sensitive information such as passwords because the environment can be viewed with ``ps e`` (e.g. ``ps auex``)

To backup the main OS and OS data (e.g. /etc, most of /var, /local-home, /root)

1. ``sudo apt install -y restic``
2. ``sudo -sH``
3. ``cd ~``
4. ``mkdir restic-files``
5. ``cd restic-files``
6. ``chmod 700 .``
7. ``touch password-file``
8. ``chmod 600 password-file``
9. ``sensible-editor password-file``
10. In the editor, add a strong password (e.g. 30 alphanumeric and special characters), then save and close (having a file with the password not ideal, but avoiding it is rather complicated, and out of scope for this article).
11. If using SFTP for backups, create a passwordless SSH keypair using:
    1. ``ssh-keygen -t rsa -f restic@piserver -C restic@piserver -N ''``
    2. Copy the contents of ``restic@piserver.pub`` to you destination's ``authorized_keys`` file.
12. [Initialize your destination restic repository](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html)
13. [Do an initial backup](https://restic.readthedocs.io/en/stable/040_backup.html)
    1. (assuming you have configured, ``~/.ssh/config`` so that ``restic@backupserver.example.com`` uses the ``restic@piserver`` created above:  

       ```bash
       restic -r sftp:restic@backupserver.example.com:/path/to/repo  --password-file ~/restic-files/password-file backup --one-file-system --exclude /var/cache/apt --cleanup-cache /etc /var /local-home /root
       ```

14. Now create a crontab entry to do this once a day:
    1. ``crontab -e``
    2. Add an entry such as:

       ```crontab
       23  2  *   *   *  restic -r sftp:restic@backupserver.example.com:/path/to/repo --password-file ~/restic-files/password-file backup --one-file-system --cleanup-cache --exclude /var/cache/apt --quiet /etc /var /local-home /root 2>&1 | logger -t restic
       ```

    3. Save and exit the editor
15. ``exit``

* For other backups, use similar steps, but using ``sudo -u data-owner -s`` (where data-owner is the user that 'owns' the data be backed up).

## Install & configure the desired services

This is basically a Debian system so the many guides for installing and configuring services on Debian (and, in many cases, Ubuntu) will be applicable.

**Enjoy!**

[^1]:
      *Should you choose to use the console (HDMI monitor and USB keyboard) there are a few things you should do, using the Raspberry Pi configuration tool: ``sudo raspi-config``, especially configure the local keyboard, network, and if applicable, wireless.
      * Repeat: For Pi on the console rather than through SSH you should configure the keyboard layout using ``raspi-config`` before changing the password, if your keyboard is not a standard UK keyboard, because the Pi console keyboard layout defaults to the type used by the Raspberry Pi Foundation, a UK non-profit organization.

[^2]:
      We only enable this because ``smartmontools`` automatically pulls in mail configuration. For an internal (no public facing internet inbound access) server, it is not recommended to send mail to public mail servers, as it will likely be seen as spam. Further, because this article describes an unencrypted root filesystem, I do not recommend adding the use of authenticated SMTP in order to send mail as an email user you have on a public mail server. That is is your email password would be stored unencrypted on your root partition.
