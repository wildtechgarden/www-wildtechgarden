---
slug: intro-to-raspberry-pi-os
aliases:
- /2020/09/20/intro-to-raspberry-pi-os/
- /post/intro-to-raspberry-pi-os/
- /deploy-admin/intro-to-raspberry-pi-os/
- /intro-to-raspberry-pi-os/
- /docs/sbc/raspberry-pi/intro-to-raspberry-pi-os/
- /sysadmin-devops/self-host/intro-to-raspberry-pi-os/
- /docs/education-academic/intro-to-raspberry-pi-os/
author: Daniel F. Dickinson
date: '2021-03-08T09:53:30+00:00'
publishDate: '2020-09-20T13:27:00+00:00'
description: "Raspberry Pi OS is the official OS for the Raspberry Pi family of educational single board computers.  Using Pi OS (including remotely)."
tags:
- debian
- educational
- linux
- raspberry-pi
- sbc
- sysadmin-devops
title: Intro to Raspberry Pi OS
toc: true
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

Raspberry Pi OS is the official operating system for the Raspberry Pi family of educational single board computers.  This article discusses some useful information on using Pi OS (including remotely) and provides links to more.

![A Raspberry Pi connected to a Netgear router’s JTAG port](/assets/images/pi-jtag.png)

### Publication Notes

This is based on, but not a conversion of, a PowerPoint presentation I created for fellow Makers at the [MakerPlace](https://midlandlibrary.com/the-mpl-makerplace/) at the [Midland Public Library](https://midlandlibrary.com/) in [Midland, Ontario](https://www.midland.ca/)

## About the Raspberry Pi

* A full-blown, credit-card sized computer.
* Based on a different processor (brains) than a typical laptop or desktop.
* Is performant enough to be useful but less than a typical desktop, laptop, or modern mobile device (cell phones, tablets, etc).
* Designed to be easy to use with electronics projects.
* Created by a U.K. non-profit.
* Intended to be an inexpensive way to learn computing  and electronics and especially th  combination of those (including robotics).
* Very popular amongst hobbyists due to low price while still being fully functional (even ignoring the appeal of easy electronics integration).
* Not designed for industrial or mission-critical applications.

{{< figure alt="Raspberry Pi 2 in an official strawberry red and white case in the palm of a human hand, with top cover removed and Pi 2 circuit board showing" caption="Raspberry Pi 2 in an official strawberry red and white case in the palm of a human hand, with top cover removed and Pi 2 circuit board showing" src="/assets/images/PiBoardOfficialCase.jpg" size="400x" >}}

## About Raspberry Pi OS

### Based on Debian GNU/Linux

* Is mostly Raspbian: Raspbian is a free operating system based on Debian optimized for the Raspberry Pi hardware. It also, comes with over 35,000 packages, (pre-compiled, easy to install, software)
* The initial build of over 35,000 Raspbian packages was completed in June of 2012. However, development of Raspbian continues.
* In additional to Raspbian, Pi OS has a small number of unique meta and ‘utility’ packages, as well as a few specially licensed versions of some commercial software. For details see: <https://github.com/RPi-Distro/pi-gen>
* New (beta) 64-bit version is not based on Raspbian according to Wikipedia ([https://en.wikipedia.org](https://en.wikipedia.org/wiki/Raspberry_Pi_OS).

## Pi CLI (Command Line)

* We’re going to concentrate on the command line because there a number of operations in Raspberry Pi OS (like most version of Linux) that are faster and easier using a command line, or are only possible use the CLI (command line interface).
* For a different take you can look at <https://magpi.raspberrypi.com/articles/terminal-help>, or do a web search – there are many articles on using the command line on the Pi. Of course like most popular topics on the web the hard part is finding a sufficiently relevant, well written, and accurate guide.
* This presentation isn’t going to try to be a full blown introduction to the Linux command line, but will instead focus on some specific items of particular interest.
* It is interesting to know that the command line takes less resources (CPU, RAM, and storage) than the desktop.

### TUI Package Installation

* A TUI is a term for an command line application that uses the entire screen, and acts similarly to a GUI but using only text. TUI stands for ‘Text User Interface’ in contrast to a ‘Graphical User Interface’ that you would use on a desktop.
* In Raspbian and Raspberry Pi OS (32-bit – not sure about the 64-bit version) you can install package called ‘aptitude’ that provides a TUI for package management (installation, removal, etc.)
* Aptitude installation is slower than plain apt, but has the advantage of a powerful search functionality, as well as being an interactive TUI instead of being a command line. In addition, like apt it is faster than using a GUI, and can be used without a desktop.
* Once you apt install aptitude you can simply execute the aptitude command on the command line.

## Remote Operation of the Raspberry Pi

* There are two major types of remote operation of the Raspberry Pi, which are:
  * Command Line
  * Desktop
* Note however, a command line variant can also execute graphical applications, under certain conditions.
* Command Line remoting consists of two main types:
  * Serial (using one or more of the UARTs on Pi header and physical connection to the controlling host).
  * SSH (Secure SHell), usually OpenSSH but Dropbear is also available.
* Desktop remoting has a number of flavours but we will only discuss VNC (Virtual Network Computing) protocol remote desktops for this presentation.

### VNC For Remote Pi Desktop

* We’ll start with VNC remote operation of the Pi because information on this type of remoting has been specifically requested.
* Depending on your situation / requirements there are two basic options with current Raspberry Pi OS:
* Use the RealVNC server shipped with Raspberry Pi OS and use a RealVNC app the ‘client’ device to control the Pi ‘host’.
* Instead of the RealVNC server use an open source VNC server and use compatible VNC ‘client’ on the device controlling the Pi ‘host’.
* The obvious advantage of the RealVNC option is that there is less to do to get it working.
* There are, however, some issues:
  * There are licensing considerations depending on what type of organization you are (if not an individual for personal use) and how many devices with which you wish to use RealVNC.
  * Much of RealVNC’s functionality require signing up for a RealVNC cloud account, and possibly incurring fees (depending on uses)
* Because it is the quickest and easiest option for personal use we will use the RealVNC option.

#### RealVNC For Remote Pi Desktop

* For non-commercial use only
* Enable RealVNC Server by:
  1. Navigating to Pi (the Raspberry Icon in the top left corner of the Pi’s screen) | Preferences | Raspberry Pi Configuration and clicking
  2. Clicking on the ‘Interfaces’ tab
  3. Selecting ‘Enable’ beside ‘VNC’
  4. Clicking OK

{{< figure alt="Screenshots of selecting Preferences from the Application Menu and Raspberry Pi 'Configuration Dialogue' open to the 'Interfaces' tab" caption="Screenshots of selecting Preferences from the Application Menu and Raspberry Pi 'Configuration Dialogue' open to the 'Interfaces' tab" src="/assets/images/2020/09/PiScreens-1-798x1024.jpg" size="400x" >}}
Author: Jonathon Killing

* After a little time you will see a Vnc icon beside the network icon on the top right hand side of the screen.
* Clicking on the Vnc icon will show a window like the one on the next slide.

#### Pi RealVNC Server Info Screen

* Make a note of the ‘dotted quad address’ (four numbers, each separated by a dot (.)). You will need this unless you sign up for a vncconnect cloud account and sign in on both the Pi and the connecting computer.
* Note also the signature and ‘catchphrase’. When you connect from the remote computer, this will help verify you’ve connected to your Pi and not some other Pi (which matters more if you are on a shared network which may have other VNC reachable hosts).

{{< figure alt="RealVNC server on a Raspberry Pi, 'info' screen" caption="RealVNC server on a Raspberry Pi, 'info' screen" src="/assets/images/2020/09/RealVNCPiInfoScreen-1.png" >}}

#### Using VNC Viewer to Connect to A Pi

{{< figure alt="RealVNC Login dialogue for client" caption="RealVNC Login dialogue for client" src="/assets/images/2020/09/RealVNCLogin-1024x729.png" >}}
Enter your username and password for your Pi, and click ‘OK’

* On the ‘client’ (connecting) computer you need to install <https://www.realvnc.com/en/connect/download/viewer/>
* You then launch ‘vnc viewer’ and enter the ‘dotted quad address’ in the search bar, or, on many networks you can enter the ‘hostname’ of your raspberry pi (if you haven’t changed it, it is ‘raspberrypi’ – obviously there are multiple pi’s on the network you need to change the hostname for connecting by name to work).
* A confirmation dialogue will pop up if this is the first time connecting, and if you accept, you will see a screen like the one on the right side of this slide.

#### VNC Session to Pi Using VNC

{{< figure alt="Screenshot of vnc viewer connected to a Pi desktop" caption="Screenshot of vnc viewer connected to a Pi desktop" src="/assets/images/2020/09/RealVNCPiSEssion-1-1024x603.png" >}}

### SSH for Command Line Access to A Pi

* While VNC access is an easy way for beginners to access the Raspberry Pi remotely, the most efficient way to remotely access a Pi is using SSH to use the command line, including launching specific GUI applications (provided one has the necessary configuration on the connecting device (namely an X server).
* For Windows versions prior to Windows 10 the best way to connect to a Pi for command line use is probably using an application called [PuTTY](https://putty.org/), however this presentation won’t deal with pre-Windows 10 usage as they are all EOL.
With an up to date Windows 10 there is now the option to use an OpenSSH client in a PowerShell or Command Prompt sessions.
* In addition, the Windows Store now has ‘Windows Terminal’ which is a Microsoft-supported open source project that provides a reasonably good, if basic, terminal for PowerShell and Command Prompt (and Windows Subsystem for Linux, but we aren’t covering that here, either). It mean that you can use OpenSSH on Windows to access remote Linux command shells (e.g. bash) and not have your terminal screen become unreadable due to terminal issues.

### Using SSH To Connect to the Pi

#### Recommended Preparation

When using SSH, public/private key authentication is recommended using as setup such as outlined below or [in a blog post I wrote about using Pi OS for a server](../deploy-admin/self-host/2020-09-08-raspberry-pi-os-for-a-server.md#configure-public-key-for-ssh-logins--recommended)

1. Open a ‘Windows Terminal’- Assuming you used the command above to generate the SSH key and that your Pi is using the default hostname (otherwise substitute your hostname or IP address): issue the command: ``scp .ssh_id_rsa.pub pi@raspberrypi:``
2. Then SSH into the Pi (note that if you don’t wish to use public/private key authentication this step is all that is required) using a command such as: ``ssh pi@raspberrypi``
3. You’ll be prompted to enter your password (which you set during Pi setup): do so.
4. You should now be at the pi command prompt and see something like: pi@raspberrypi:~$
5. Execute:

   ```sh
   mkdir .ssh; chmod 700 .; chmod 700 .ssh; mv id_rsa.pub .ssh/authorized_keys; chmod 600 .ssh/authorized_keys; exit
   ```

#### Connecting to Raspberry Pi with a Keypair

* If you’ve followed the instructions on the previous slide you can now SSH into your Pi using the keypair you generated with ssh-keygen. You will be prompted for the keypair's (really the private key’s) password to login instead of the password for your user.
* To avoid having to enter a password every time you want to SSH into the Pi, you can use the OpenSSH agent to remember the passphrase – this is relatively safe because it still requires the private key and does not transmit the password to the Pi, but using public/private key encryption to authenticate to the Pi.
* You may also be interested in Microsoft’s Managing OpenSSH Keys Page.
* With the install of the OpenSSH client a service known as ‘ssh-agent’ should have been installed.
* To enable have it start on boot and start it now, launch an Administrative PowerShell, and enter* Set-Service –Name ‘ssh-agent’ –StartupType ‘Automatic’
* Start-Service ‘ssh-agent’* Now (and once each time you boot), in a Windows Terminal use the command: ``ssh-add``, and then enter key password.

#### Using SSH to Connect to the Pi, Part III

* Now you can connect to your Raspberry Pi command line using SSH (ssh pi@raspberrypi).
* If you also install Xming, VcXsrv, or a more up-to-date fork of VcXsrv you can use ``ssh –CY pi@raspberrypi “name-of-an-X11-program”`` (X11 is the protocol used for most GUI applications on Linux) to launch GUI applications.
* An SSH session could look similar to the screenshot shown.

{{< figure alt="Screenshot of a Pi OS SSH login screen" caption="Screenshot of a Pi OS SSH login screen" src="/assets/images/2020/09/WindowsSSHSession-1.png" >}}

## Sharing Files from a Pi to Windows

There are a number of guides to installing and configuring Samba that can be found be a web search, but the actual connection from Windows is under-documented, so this presentation will focus on the later and only briefly describe the former.

1. Install and Configure Samba on the Pi
   1. On the Pi execute sudo apt install samba
   2. Create the folder you want to share (e.g. /srv/shared-folder)
   3. On the Pi execute sudoedit /etc/samba/smb.conf
   4. Create a ‘share’ for the shared folder by adding:

      ```ini
      [shared_folder]
       read only = no
       browseable = yes
       guest ok = no
       path = /srv/shared-folder
      ```

   5. Restart Samba by executing the command: ``systemctl restart smbd nmbd``
   6. For each user who should have access to the share execute: ``sudo smbpasswd –a username``
   7. Connect from Windows (see next slide).

## Connecting to Samba from Windows

### Make sure Windows 10 File and Printer Sharing is Enabled

{{< figure alt="Screenshot of 'Network and Sharing Center' in Windows 10 'Control Panel'" caption="Screenshot of 'Network and Sharing Center' in Windows 10 'Control Panel'" src="/assets/images/2020/09/control-panel-network-and-sharing-1-1024x583.png" >}}

{{< figure alt="Windows 10 Network and Sharing Center with 'Changed advanced sharing settings' circled in red" caption="Windows 10 Network and Sharing Center with 'Changed advanced sharing settings' circled in red" src="/assets/images/2020/09/network-and-sharing-advanced-1.png" >}}

{{< figure alt="Windows Advanced Sharing Settings screen" caption="Windows Advanced Sharing Settings screen" src="/assets/images/2020/09/file-and-printer-sharing-1.png" >}}

### Populate Windows Credentials for the Samba Server

{{< figure alt="'Windows Credentials' highlighted in Windows 10 Control Panel" caption="'Windows Credentials' highlighted in Windows 10 Control Panel" src="/assets/images/2020/09/WindowsCredentialsControlPanel-1.png" >}}

* Windows can be finicky about connecting to a Samba share, and can end up in a state where one needs to logout, or even restart the Windows computer for the connection to be successful.
* A method I have found that seems to work well is to use Windows ‘Credential Manager’ before making any attempt to find or use the Pi or the Samba share.
* Credential Manager is found in the Control Panel in Windows and is shown on the right in the ‘Windows Credentials’ section.

### Using Windows Credential Manager

{{< figure alt="Dialogue for adding a credential to 'Windows Credential Manager'" caption="Dialogue for adding a credential to 'Windows Credential Manager'" src="/assets/images/2020/09/WindowsCredentialAddingACredential-1.png" >}}

* In ‘Credential Manager’ select ‘Add a Windows Credential’* You will see a screen such as the one on the right.
* In ‘Internet or network address’ enter the hostname of your Pi (e.g. raspberrypi) or it’s IP address (a hostname is more likely to work well and not change).
* Then enter the username and password you configured using smbpasswd –a
* Click OK

### Use File Explorer to Map a Network Drive

{{< figure alt="Mapping a network drive in Windows 10" caption="Mapping a network drive in Windows 10" src="/assets/images/2020/09/MapNetworkDriveDialogue-1.png" >}}

* Open ‘File Explorer’ (remember we’re assuming Windows 10; earlier versions of Windows may be slightly different).
Select the ‘Computer Tab’ and then ‘Map Network Drive’
* Choose the letter to assign to the network drive
* In the folder field enter the UNC of the network share. That will look like: \\hostname\shared-folder
* Make sure ‘Connect using different credentials’ is unchecked (as in the screenshot) as you’ve already entered your credentials in Credential Manager.
* Click Finish.

### Windows Connected to a Samba Share

{{< figure alt="Windows 10 File Explorer showing the directory of an attached network drive" caption="Windows 10 File Explorer showing the directory of an attached network drive" src="/assets/images/2020/09/ConnectedToSambaNetworkDrive-1.png" >}}

## Additional Reading and Videos

* <https://www.linkedin.com/learning/topics/linux-2?trk=lynda_redirect_learning> — There is a wealth of different course options under this link
* <https://www.freecodecamp.org/news/a-beginners-guide-to-surviving-in-the-linux-shell-cda0f5a0698c/>
* <https://lifehacker.com/a-command-line-primer-for-beginners-5633909>
* <https://www.howtogeek.com/howto/42980/the-beginners-guide-to-nano-the-linux-command-line-text-editor/>
* <https://www.linux.com/training-tutorials/complete-beginners-guide-linux/>
* <https://www.linkedin.com/learning/learning-linux-command-line-2018?trk=lynda_redirect_learning>
* [raspberry-pi-os-for-a-server](../deploy-admin/self-host/2020-09-08-raspberry-pi-os-for-a-server.md)
