---
slug: common-windows-and-linux
aliases:
    - /docs/sysadmin-devops/windows-and-linux/common-windows-and-linux/
    - /sysadmin-devops/windows-and-linux/common-windows-and-linux/
    - /deploy-admin/common-windows-and-linux/
    - /docs/deploy-admin/windows-and-linux/common-windows-and-linux/
author: Daniel F. Dickinson
categories:
date: '2021-04-25T00:30:00+0400'
publishDate: '2021-04-25T00:30:00+0400'
tags:
- linux
- sysadmin-devops
- windows
- windows-and-linux
title: Common setup for Windows + Linux systems
description: "These are some personal notes about setting up a very nice combined
Windows and Linux productivity and development environment."
summary: "These are some personal notes about setting up a very nice combined
Windows and Linux productivity and development environment."
---

{{< details-toc >}}

## Preface

These are some personal notes about setting up a very nice combined
Windows and Linux productivity and development environment.  It uses
open source software combined with some key proprietary pieces on a single
machine.  This is now possible when using a Windows 10 workstation[^1].

I have thought about automating this (especially since I have a tendency to refresh systems fairly often), but I make enough changes between installs, and I'm using retail Windows licenses rather than volume licenses, so automation is not really practical.

It is important to note this environment is geared to those who are used to the
Linux ecosystem and are migrating to the new hybrid model.

## Installation notes

Use at least Windows 10 Pro Version 2004, with Version 21H1 preferred.
Windows 10 Home might work for some of this, but not all features are available.

### The parts that come with your Windows license

#### The base Windows install (Linux Libvirt/KVM virtual machine)

See [Windows in a Libvirt/KVM virtual machine](2020-10-27-windows-in-a-libvirt-kvm-vm.md) for the [instructions for the installation of Windows 10 Pro in a Libvirt/KVM virtual machine](2020-10-27-windows-in-a-libvirt-kvm-vm.md#setting-up-the-virtual-machine-on-a-linux-host)

#### The base Windows install (physical hardware)

I won't go into a lot of detail here as there are many guides on basic Windows
installation, instead I will just a list a few key points.

* Make sure your machine is activated and fully up to date with 'Windows Update'.

##### Configure language and regional settings as appropriate

1. In the `Settings` app, select `Time & Language`
2. Select `Language`
3. If your 'Windows display language' is for your region you probably don't need to do anything more.
4. Otherwise, look in the list of 'Preferred Languages'
5. Select the language corresponding to your region, or 'Add a language' if your language and
   region are not in the list.
6. Select `Options` for your language and region.
7. For any and all `Download` buttons in your Language options page, click `Download`.
8. Wait for the downloads and installs to complete.
9. Verify your desired keyboard type and layout is first (or only) in the list of keyboard types/layouts
10. Go back to the main `Language` page.
11. Set your `Windows display language` to your language and region.

##### Tweak base install

* Tweak the base install (before adding any software or apps) and settings to
  your preferred base configuration[^2].

#### Configure 'For developers' in 'Upgrades & Security'

* You should go through these settings as many of them are useful to power
  users and developers – be careful though as there are often security implications to the options.  I certainly don't enable all the options.
* You should review the notes in [configuring for developers when in a Libvirt/KVM VM](2020-10-27-windows-in-a-libvirt-kvm-vm.md#configure-for-developers-in-upgrades--security) and [configuring for developers when on physical hardware](2020-08-20-windows-and-linux-in-one.md#configure-for-developers-in-upgrades--security) as operating in a VM is different from physical hardware for the choices you will can make.

#### Add Windows (system) features

##### Developer essentials

This could almost be part of the 'Base Windows Install' except that we are
adding components that wouldn't make sense for an environment that doesn't
need Linux and/or some handy developer features.

* Add WSL and possibly[^3] upgrade to WSL2 — Follow [Microsoft's Guide to Installing WSL and WSL2](https://docs.microsoft.com/en-us/windows/wsl/install).

##### Useful features from Programs & Features in Control Panel

* Install Hyper-V if you need virtualization (your machine or virtual machine needs to support it) — Also enable all the Hyper-V options in the control panel applet.  If Hyper-V is not supported on your machine you can install VirtualBox using Chocolatey (see below) (again provided your machine for virtual machine supports it).
* Extras — Likewise, you might want the "Telnet Client" and "TFTP Client", depending on your planned uses.
* "Services for NFS" — There is also a small possibility you will benefit from "Services for NFS", depending on the hosts on your network.

##### Allowing SSH into your machine (optional)

* Install "OpenSSH Server" if you plan on using SSH **into** the machine or virtual machine — See   [Microsoft's instructions for installing OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse), and the related configuration guides. Similar to the 'Remote Desktop' option, if you have enabled networking into the machine or virtual machine so that you can use SSH into it, you probably should change the default firewall rule for SSH to be more restrictive (e.g. Private networks only).

#### Add some (free) bits from the Windows Store

* Windows Terminal — It's a Microsoft Open Source project that you can
  participate in on GitHub.  It is also has quite a nice and usable terminal, that is
  only likely to get better with time.  Currently it's nice and light.

* WinDbg Preview — This allows you to look at Windows 'Crash dumps'

* A Linux distribution from the available choices – I now use Ubuntu LTS but have used Debian. You can  use whichever suits your needs.

#### Maybe a paid Microsoft purchase (besides Windows)

* Microsoft 365 — If you can afford it, there are may be advantages over a free
  office suite, which I'll mostly leave it to other sites to discuss, except…

* I will say I'm not so sure about this one. I like the native desktop apps, but
  I am not a fan of the Software as a Service (SaaS) model of MS 365. As it happens I have licenses for Office 2016 Home and Business which gives me the desktop apps I want from the MS 365 offering, and without all the SaaS baggage.

* I think the standalone 2019 offering is too expensive, so in future I may abandon the Microsoft office products altogether and just use LibreOffice

* LibreOffice software is really more than enough for what I actually _need_, and
  MS Office is getting to be too much of a hassle.

* Besides that, on my Linux desktops I don't have MS Office native apps as an
  option anyway.

* Your call for your install.

### The rest (on the Windows side)

#### Install Chocolatey (a package manager for Windows)

Just [follow the official Chocolatey install guide](https://chocolatey.org/install).

#### Install software for Windows available through Chocolatey

**NOTE:** The original software licenses still apply so it is important that
they are compatible with your situation.  You can verify that by using
the [Chocolatey online package browser](https://community.chocolatey.org/packages), or
`ChocolateyGUI` (a graphical interface for Chocolatey).

Most of the software is open source and ought to be no problem for internal use;
if you are planning on 'distributing' anything then you need to pay close
attention to licensing terms.  I've made note of any software that you may need
to play closer attention to the licensing terms, even for internal use, for which
I am aware of the more complicated situation.

#### Install regular user software

##### Software applicable to Windows in VM on a Linux host

* When running Windows in a Linux virtual machine, one doesn't need the same set of packages one would when running Windows on bare metal because much of the software available for Windows is also available for Linux and it makes more sense to run software natively (i.e. on the host) when possible.

* The following is a list of software that is useful even when running in a Windows virtual machine, with most software you use running on the Linux host.

* This particular list is for regular users (i.e. not related to Linux, development, or system administration, those are listed later). Obviously you will want to modify according to your needs and wants.

```PowerShell
choco install 7zip.install adobereader chocolateygui Firefox gpg4win keepassxc libre-hardware-monitor notepadplusplus.install paint.net rufus screentogif synctrayzor vlc wincompose.install
```

| Package                | Name                    | Description                                                                                                                                                                                   |
| ---------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 7zip                   | 7-zip                   | Compress/Decompression and archiving/unarchiving                                                                                                                                              |
| adobereader            | Adobe Acrobat Reader DC | The official Adobe PDF reader; proprietary license                                                                                                                                            |
| chocolateygui          | ChocolateyGUI           | GUI for Chocolatey                                                                                                                                                                            |
| Firefox                | Firefox                 | Privacy-oriented Web Browser                                                                                                                                                                  |
| gpg4win                | GnuPG for Windows       | Public/Private Key encryption tool                                                                                                                                                            |
| keepassxc              | KeePassXC               | Password management tool                                                                                                                                                                      |
| libre-hardware-monitor | LibreHardwareMonitor    | System (CPU, memory, disk, temp, and so on monitoring in system tray)                                                                                                                         |
| notepadplusplus        | Notepad++               | A better notepad (text editor) for Windows                                                                                                                                                    |
| paint.net              | Paint.NET               | Photo editing software                                                                                                                                                                        |
| rufus                  | Rufus                   | USB and SD card writer                                                                                                                                                                        |
| screentogif            | ScreenToGif             | Screen, webcam, and sketch board recorder and editor                                                                                                                                          |
| synctrayzor            | SyncTrayzor             | System tray and GUI for Syncthing, for syncing files without 'the cloud' — note that nowadays I use a local Nextcloud server and use ``nextcloud-client`` in my machines and virtual machines |
| vlc                    | VideoLan Client         | Video and audio player                                                                                                                                                                        |
| wincompose             | WinCompose              | Compose key for windows – intuitive entry of unusual characters                                                                                                                               |

##### Software you might want on bare metal Windows

The following list of software is interesting if you are running Windows on
bare metal (that are not listed above).

```PowerShell
choco install audacity audacity-lame calibre cdburnerxp dia freac gimp InkScape libreoffice-fresh kmymoney quodlibet rufus scribus workrave zoom
```

| Package           | Name              | Description                                                                                                                                                                           |
| ----------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| audacity          | Audacity          | Audio recording and editing software                                                                                                                                                  |
| audacity-lame     | LAME for Audacity | Allow Audacity to create MP3 files                                                                                                                                                    |
| calibre           | Calibre           | e-Book Library Management                                                                                                                                                             |
| cdburnerxp        | CDBurnerXP        | Create and burn data CD, DVDs, and Blu-ray                                                                                                                                            |
| dia               | Dia               | Create and edit diagrams                                                                                                                                                              |
| freac             | Fre:ac            | Audio file converter/encoder/decoder and CD ripper                                                                                                                                    |
| gimp              | GIMP              | A very powerful graphics / image manipulation program                                                                                                                                 |
| InkScape          | InkScape          | Vector graphics creator and editor                                                                                                                                                    |
| kmymoney          | KMyMoney          | Personal Financial Management                                                                                                                                                         |
| libreoffice-fresh | LibreOffice Fresh | Stable version of LibreOffice                                                                                                                                                         |
| quodlibet         | Quod Libet        | Music Collection / Player Software                                                                                                                                                    |
| rufus             | Rufus             | USB and SD card writer                                                                                                                                                                |
| scribus           | Scribus           | Desktop publishing software (cross-platform)                                                                                                                                          |
| workrave          | Workrave          | RSI prevention utility (require regular breaks)                                                                                                                                       |
| zoom              | Zoom              | Video conferencing / chat.  **NB** If you have more than one computer your probably need to install manually due to download restrictions; also pay attention to the licensing terms. |

#### Install useful power tools

##### Power tools applicable to Windows in VM on a Linux host

```PowerShell
choco install putty.install rsync sysinternals vcxsrv wireshark
```

| Package      | Name         | Description                                                                                             |
| ------------ | ------------ | ------------------------------------------------------------------------------------------------------- |
| putty        | PuTTY        | SSH GUI (unrelated to OpenSSH above)                                                                    |
| rsync        | rsync        | One-way file sync common on other OSes                                                                  |
| sysinternals | SysInternals | Power tools for Windows                                                                                 |
| vcxsrv       | VcXsrv       | An X-Windows server for Windows; useful for running X11 applications remotely and using a local display |
| wireshark    | Wireshark    | Watch and analyze activity on your network                                                              |

##### Power tools you might want on bare metal Windows

```PowerShell
choco install OpenSSL.Light xca
```

| Package       | Name    | Description                                         |
| ------------- | ------- | --------------------------------------------------- |
| OpenSSL.Light | OpenSSL | The command line tool for SSL certificates and more |
| xca           | XCA     | SSL certificate creation and management             |

#### Install development software

##### Development software applicable to Windows in VM on a Linux host

This is highly dependent on what you are developing and what languages you are
using. This list is an example.

```PowerShell
choco install git git-credential-manager-for-windows golang openscad vagrant vim virtualbox vscode yarn
```

| Package                            | Name                               | Description                                                                                                                     |
| ---------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| git                                | Git for Windows                    | The major version control and source code management system in the software world                                               |
| git-credential-manager-for-windows | Git Credential Manager for Windows | Manage Git credentials using the Windows system secrets store                                                                   |
| golang                             | Go                                 | The Go language and standard library                                                                                            |
| openscad                           | OpenSCAD                           | Programmatic CAD                                                                                                                |
| vagrant                            | Vagrant                            | command line tools for creating and using virtual machines (vagrant 'boxes') similar to the way one would use docker containers |
| virtualbox                         | Oracle VirtualBox                  | Run Virtual Machines under Windows (with or without Hyper-V).                                                                    |
| vscode                             | Visual Studio Code                 | Code and text editor and development environment, and more                                                                      |
| yarn                               | Yarn                               | An improved package manager for Node.js                                                                                         |

##### Development software you might want on bare metal Windows

This is highly dependent on what you are developing and what languages you are
using.  The following is a list that reflects my current situation.

```PowerShell
choco install arduino docker-compose docker-desktop html-tidy hugo nodejs.install pandoc shellcheck thonny
```

| Package        | Name           | Description                                                                                                 |
| -------------- | -------------- | ----------------------------------------------------------------------------------------------------------- |
| arduino        | Arduino        | IDE for developing Arduino sketches                                                                         |
| docker-compose | Docker Compose | Tool for launching and managing Docker machines                                                             |
| docker-desktop | Docker Desktop | Docker for modern machines, integrates with WSL2; for older machines use Docker Toolbox instead             |
| html-tidy      | Tidy           | Validate and clean HTML5                                                                                    |
| hugo           | Hugo           | Static website generator                                                                                    |
| nodejs         | Node.js        | JavaScript as a language for cross-platform apps and services; includes NPM the package manager for Node.js |
| pandoc         | Pandoc         | Convert between document formats (e.g. markdown, pdf, docx, xml, html, and tex) on the command line         |
| shellcheck     | ShellCheck     | Check bash / sh / dash / ksh scripts for syntax and common errors and style issues                          |
| thonny         | Thonny         | Python IDE for beginners                                                                                    |

#### Windows development

While I don't need it, you want [Visual Studio](https://visualstudio.microsoft.com/) if you need to develop software for Windows only, the Microsoft way.  Chocolatey can probably install what is needed by most developers. Verify what you are installing though — licensing can be tricky here.

In addition to the Visual Studio Installer and Visual Studio 20XX Community or Visual Studio 20XX Build Tools core applications you will want to install 'workloads' that support the type of applications you are wanting to develop or to which you wish to contribute. A fairly 'kitchen sink' example install command is given below.

```PowerShell
choco install -y visualstudio2019buildtools visualstudio2017feedbackclient visualstudio2017buildtools VisualStudio2017Community visualstudio2019community visualstudio2017-workload-visualstudioextension visualstudio2019-workload-visualstudioextension visualstudio2017-workload-python visualstudio2017-workload-azure visualstudio2017-workload-visualstudioextensionbuildtools visualstudio2015-nugetpackagemanager microsoft-build-tools visualstudio2017-remotetools visualstudio2019-remotetools visualstudio2017-workload-node visualstudio2019-workload-node visualstudio2019-workload-azure visualstudio2019-workload-python visualstudio2019-workload-visualstudioextensionbuildtools visualstudio2017sql visualstudio2017-performancetools visualstudio2019-performancetools visualstudio2017-workload-nativecrossplat visualstudio2019-workload-nativecrossplat visualstudio2017-workload-azurebuildtools visualstudio2017-workload-nodebuildtools visualstudio2019-workload-azurebuildtools visualstudio2017-workload-netcorebuildtools visualstudio2017-workload-manageddesktop visualstudio2019-workload-manageddesktop visualstudio2017-workload-vctools visualstudio2019-workload-vctools visualstudio2017-workload-netcoretools visualstudio2017-workload-netcrossplat visualstudio2017-workload-netweb visualstudio2017-workload-universal visualstudio2017-workload-webcrossplat visualstudio2019-workload-netcrossplat visualstudio2017-workload-nativedesktop visualstudio2017-workload-data visualstudio2019-workload-universal visualstudio2019-workload-netweb visualstudio2019-workload-nativedesktop visualstudio2019-workload-netcoretools visualstudio2017-workload-universalbuildtools visualstudio2019-workload-nodebuildtools visualstudio2019-workload-universalbuildtools visualstudio2019-workload-manageddesktopbuildtools visualstudio2019-workload-netcorebuildtools visualstudio2017-workload-webbuildtools visualstudio2019-workload-webbuildtools visualstudio2017-workload-manageddesktopbuildtools windowsdriverkit10 vcredist2017
```

#### Android development

E.g. `choco install AndroidStudio`

#### Additional software

There may be additional software you want to install that is not available from
the Windows Store or Chocolatey.  That's not covered here, although a personal recommendation is [Zim Desktop Wiki](https://zim-wiki.org). Unfortunately the version in Chocolatey is rather old and due to the technology used in the installer, it gets a number of false positives on the virus scan.

### Linux side

I don't cover installation of packages and configuration of the general Linux
environment except as is particular to this hybrid setup, as there are a great
many guides for general Linux setup and configuration already written, and the
WSL2 environment doesn't have much that isn't generic Linux.

## Configuration notes

Now that the software is installed there is a bit of configuration to do.

### Configuring WSL so Windows filesystems have proper Unix permissions

In the WSL environment you should add `/etc/wsl.conf` containing something like:

```ini
[automount]
enabled = true
options = metadata,uid=1000,gid=1000,umask=0022,fmask=0011

[network]
generateHosts = true
generateResolvConf = true
```

See [Configuring WSL launch settings](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configuration-settings-for-wslconf)

Once you restart WSL (which involves more than just closing your current WSL
terminal; the easiest way to guarantee a WSL restart is to reboot Windows),
while in WSL files and directories from Windows (e.g. under /mnt) will have more
normal Unix permission. You will be able to override with chmod for the
effective permissions _in WSL_.  Also note that in some cases there are Windows
ACLs that also affect your effective permissions.

And finally, it's generally not possible to delete files which are opened by
another process in Windows, and therefore in WSL (which differs from plain
Linux).

### Configure Visual Studio Code for developing in WSL/WSL2

See the [Visual Studio Code Guide to Developing in WSL](https://code.visualstudio.com/docs/remote/wsl)

### Using Windows SSH client for Git for Windows

* This assumes use of SSH public/private keys for Git.  If you prefer to use the
  Git Credential Manager for Windows with Git over HTTPS and using API keys, see
  [Git Credential Manager for Windows configuration](https://microsoft.github.io/Git-Credential-Manager-for-Windows/Docs/Configuration.html)

* See also [Microsoft's managing OpenSSH keys page](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)

#### Enable the 'ssh-agent' service

* On the latest Windows 10 Pro OpenSSH agent should be installed by default.
  If not it can be installed by installing the "OpenSSH Client" Windows 'feature'.
* Execute the commands:

  ```PowerShell
  Set-Service -Name 'ssh-agent' -StartupType 'Automatic'
  Start-Service 'ssh-agent'
  ```

#### Make Windows OpenSSH client the default for Git for Windows

To set this for a single user set the environment variable `GIT_SSH_COMMAND` to point to
the OpenSSH binary in the user's environment variables.

```PowerShell
[Environment]::SetEnvironmentVariable("GIT_SSH_COMMAND", "cat - | $((Get-Command ssh).Source.Replace('\','/'))", [System.EnvironmentVariableTarget]::User)
```

Also, makes sure ``GIT_SSH`` is unset for the user:

```PowerShell
[Environment]::SetEnvironmentVariable("GIT_SSH", "", [System.EnvironmentVariableTarget]::User)
```

To set it for all users, set `GIT_SSH_COMMAND` in the system environment variables.

In an admin PowerShell:

```PowerShell
[Environment]::SetEnvironmentVariable("GIT_SSH_COMMAND", "cat - | $((Get-Command ssh).Source.Replace('\','/'))", [System.EnvironmentVariableTarget]::Machine)
```

Also, makes sure ``GIT_SSH`` is unset in the system environment:

In an admin PowerShell:

```PowerShell
[Environment]::SetEnvironmentVariable("GIT_SSH", "", [System.EnvironmentVariableTarget]::Machine)
```

#### Configure Git for Windows for better Linux compatibility

| Line | Purpose                                                                                                                         |
| ---- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Ignore changes do file 'mode' bits (e.g. execute permissions)                                                                   |
| 2    | Make the default line ending for files Unix mode line endings.  Windows 10 2004 supports text/source files of this type easily. |
| 3    | Disable changing the line endings depending on whether checking out on Windows or under WSL.                                    |
| 4    | Set the default user name for commits and emails                                                                                |
| 5    | Set the default user email for commits and emails                                                                               |
| 6    | Make the default credential manager Git Credential Manager for Windows                                                          |

```PowerShell {linenos=table}
git config --global core.fileMode false
git config --global core.eol lf
git config --global core.autocrlf false
git config --global user.name "Your Name"
git config --global user.email "Your email address"
git config --global credential.helper manager
```

#### A bit of extra GfW configuration for safer pulls

This option prevents pulls from creating a merge or a forced update (i.e.
rewriting history) or rebase.  You can still `git fetch` and manually merge or
rebase as necessary.

```PowerShell
git config --global pull.ff only
```

### Enabling backups of WSL

Using a tool (in WSL) that can be run on a period basis and does 'push' backup
is recommended.  The tool I was using is [Borg](https://www.borgbackup.org/) but there are
other options like [Restic](https://restic.net) (which I now use).

1. Install your backup program (e.g. `apt-get install borgbackup`).
2. Create a script to do the backup.
   1. You want your 'regular' user for a home dir only backup.
   2. If  you want to backup parts like /etc, you want the script to be
      executable by root, but readable only by root (or at least any passwords,
      etc.)
3. In Windows, as the user account in which you installed the Linux distribution
   use `Task Scheduler` to create a period task that runs the script.
   1. Create a task (you probably want it to run even if you are not logged in).
   2. Choose your triggers.
   3. For the action:
      1. Use `wsl.exe` as the program to execute: **NB** Using the bare filename
         and making the `C:\WINDOWS\System32` the working folder is (was?) required due
         to a bug in `Task Scheduler`.
      2. Set the folder to use as `C:\WINDOWS\System32`
      3. Set the arguments to `-u user_to_runas -- /path/to/your/script`.
   4. Complete creating the task.
   5. Save and do a test run.  The 'action' should complete with exit code 0.

### OpenSSH server configuration documentation by Microsoft

See also [Microsoft's Guide to Configuring OpenSSH Server](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration)

### The rest, as suits your needs and preferences

The rest is about learning what makes for a comfortable environment for you.  I
personally tend to get annoyed with 'opinionated' or 'perfect' setup guides, and
am trying to create more flexible set of suggestions that can easily be adapted
to suit _you_.

## Footnotes

[^1]: The Windows 10 20H2 Update WSL2 (Windows Subsystem for Linux 2) combined
with a number of other Windows enhancements has made the promises of
WSL (that one can develop Linux software and firmware on Windows and easily
run Linux binaries on Windows machines) much more of a reality.  It is now
practical to develop and run many types of Linux non-X11[^4] software on Windows.
Even the original WSL is more usable than when first released for general
availability.  The parallel development of
[Visual Studio Code](https://code.visualstudio.com/) (a very nice
cross-platform editor and development environment) is an important factor as well.

[^2]: Specifics depend on you or your organization. A collection of things I
like to ensure on a single user desktop is:

* Use BitLocker hard drive encryption (enable the non-TPM option if necessary).
* Require using of Ctrl-Alt-Del (**if** on real hardware) so you use the
  'Secure Desktop' to enter credentials
* Increase the UAC settings so you always are prompted for credentials
  on the secure desktop, and never just click through for elevation to
  Administrator access.
* Set a soft lockout for too many password attempts.
* Don't use a maximum password age (it causes more problems than it helps).
* Enforce at least eight characters passwords with complexity requirements met.
* For SMB encrypt all communications and require NTLMv2 (if you have a external device that is too old to support that, it's time to upgrade it, unless, perhaps, you are experimenting with a new OS that isn't mature enough to have implemented this yet).
* Set a machine inactivity timeout (which doesn't rely on setting the screensaver per-user to ensure that the desktop will lock when not in use).
* Use File History for backing up the folders for backing up your data.  It's not a bare metal restore option, but it makes sure you have your data backed up, as well as giving you the ability to go back to previous versions of files. Needless to say you should make sure your back up location is encrypted on disk. It is also important to use 'Advanced Options' and **check the Event Log for errors** on a regular basis.
* Enable system checkpoints.
* Once you've got a good base image, don't forget to make a system image.

[^3]: In my opinion, there are two main conditions under which one would not use WSL2:

* One's machine (or virtual machine) doesn't support WSL2 (e.g. due to missing CPU features).
* One needs the bare metal virtualization mode of a hypervisor other than Hyper-V (e.g. if you need VMWare or VirtualBox with their native virtualization rather than the Hyper-V compatible virtualization).

[^4]: Actually, while not recommended, it is possible to use VcXsrv or Xming (X
      servers for Windows) in order to be also be able to run X11 apps from
      WSL/WSL2 on your Windows desktop.  The free version of Xming and VcXsrv
      (which is free) are somewhat dated.
