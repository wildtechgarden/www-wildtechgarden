---
slug: base-install
aliases:
    - /docs/sysadmin-devops/windows-and-linux/base-install/
    - /docs/sysadmin-devops/windows-and-linux/a-more-windows-centric-approach/base-install/
    - /sysadmin-devops/windows-and-linux/a-more-windows-centric-approach/base-install/
    - /deploy-admin/a-more-windows-centric-approach/base-install/
    - /docs/deploy-admin/windows-and-linux/a-more-windows-centric-approach/base-install/
title: "Base install of Windows 10"
author: Daniel F. Dickinson
date: '2021-07-13T15:16:00-04:00'
publishDate: '2021-07-15T06:04:00-04:00'
tags:
- sysadmin-devops
- windows
- windows-and-linux
description: "A quick guide to a base install of windows, for completeness."
summary: "A quick guide to a base install of windows, for completeness."
---

{{< details-toc >}}

## Base install

**NB** The author doesn't have a tripod, nor the feeling of relevance for this part of the guide, so the quality of screen photos here is not as good as other guides out there—this version is only included in case you need the information right here, rather than to draw people to the site for an often-covered topic.

### Boot from installation media

* [Windows 10 installation via bootable media](https://www.mychoicesoftware.com/pages/support-windows-10-installation-via-bootable-media)
* [Windows 10 boot from installation media for certain ASUS motherboards](https://www.asus.com/support/FAQ/1039507)

### Core install

1. Once Windows Setup completes booting, select your 'Time and currency format' (this sets your default country and your language variant) then click 'Next'.
   ![Windows 10 Pro English Great Britain Boot Screen](/assets/images/windows-10-install/win10pro-en-gb-boot-screen.png)
2. Click on the 'Install now' button on the next page.
   ![Windows 10 Pro English Install Button Screen](/assets/images/windows-10-install/win10pro-install-button.png)
3. If this is the first time installing Windows 10 Pro on this computer, enter your product key on the next screen, otherwise select "I don't have a product key" (Windows Activation should recognize that this computer already has a license when it does its thing), then click 'Next'.
   ![Windows 10 Pro English Product Key Entry (Activation) Screen](/assets/images/windows-10-install/win10pro-install-product-key-page.png)
4. Select the Edition of Windows 10 for which you have a product key and you wish to install (this guide assumes Windows 10 Pro), and click 'Next'.
   ![Windows 10 Edition Selection Page](/assets/images/windows-10-install/windows-edition-selection-screen.png)
5. Accept the license agreement after reading it (it's not like you have a choice if you want to use Windows)
   ![Windows 10 License Acceptance Page](/assets/images/windows-10-install/win10pro-license-agreement.png)
6. Choose "Custom: Install Windows only (advanced)" since we want a fresh install.
   ![Windows 10 Choose Installation Type (Upgrade or Install)](/assets/images/windows-10-install/win10pro-choose-install-not-upgrade.png)
7. On the install location screen, if you see an OEM partition, DO NOT delete it.
   ![Windows 10 install location screen, warning on OEM partition](/assets/images/windows-10-install/win10pro-hdd-pre-leave-oem-partition.png)
8. Delete any other partitions, select the resulting free space, and click 'Next'.
   ![Select free space from delete all but OEM partition on Windows 10 install location screen](/assets/images/windows-10-install/win10pro-install-location-page-delete-all-but-oem.png)
9. The installer will go through a number of steps.
   ![The installer performing the initial install](/assets/images/windows-10-install/win10pro-install-progress-screen.png)
10. The installer will then reboot.
   ![The installer counting down to reboot](/assets/images/windows-10-install/win10pro-install-countdown-to-reboot.png)

### Initial setup wizard

Your computer will reboot (possibly more than once) and eventually start the Windows setup wizard, starting with asking you what country you are in; the wizard steps are as follows:

1. Choose your region (this may be a country or a Province/State).
   ![List of countries with Canada highlighted](/assets/images/windows-10-install/win10pro-setup-wizard-01-country.png)
2. Choose your keyboard layout.
   ![List of keyboard layouts with US (QWERTY) highlighted](/assets/images/windows-10-install/win10pro-setup-wizard-02-keyboard.png)
3. Choose whether to add another layout (this guide chooses 'Skip', as the author doesn't need another layout).
   ![Choice of adding another keyboard layout](/assets/images/windows-10-install/win10pro-setup-wizard-03-another-keyboard-layout.png)
4. Windows will emit various messages to let you know it is doing 'stuff' and to wait for it complete. For example:
   ![Windows 'Just a moment...' screen](/assets/images/windows-10-install/win10pro-setup-wizard-04-please-wait.png)

#### Primary user (Administrator) account

The next steps are the setup of the primary user. The primary user is part of the Administrators group, and for a personal use computer has full control of the computer. Since this guide is only intended to cover personal use, we won't worry about the 'school or work' scenario.

1. Choose to set up for Personal Use (since that is what this guide is about).
   ![Chose of setting of as a 'Personal Use' computer or an organization controlled 'School or Work' computer](/assets/images/windows-10-install/win10pro-setup-wizard-05-choose-personal-use.png)
2. Enter your Microsoft Account email address (if you don't have a Microsoft Account you will need to create one). While you have the option of creating a local/offline (non-Microsoft) account, this guide is written with the assumption you are using an existing Microsoft Account.
   ![Prompt for your Microsoft account (or to use a local/offline account instead, shown on the bottom left)](/assets/images/windows-10-install/win10pro-setup-wizard-06-enter-your-microsoft-account-email-address.png)
3. When prompted enter your password.
   ![Prompt for your Microsoft Account password](/assets/images/windows-10-install/win10pro-setup-wizard-07-enter-your-password.png)
4. If prompted, enter your second factor authentication code (assuming you have two factor authentication (2FA) set up, which you really should)
5. You will be prompted to create a PIN (or to skip). I recommend creating a PIN, as it allows use of 'Windows Hello'.
   ![Prompt to choose to create a PIN](/assets/images/windows-10-install/win10pro-setup-wizard-08-prompt-to-create-a-pin.png)
6. Enter and confirm your new PIN.
   ![PIN creation and confirmation dialogue](/assets/images/windows-10-install/win10pro-setup-wizard-09-pin-creation-dialogue.png)
7. You will next be asked to make choices about a series of privacy-related options (e.g. choosing to send Microsoft full diagnostics and usage patterns, or only basic diagnostics). This guide won't walk through those steps as it's a rather individual matter what one is comfortable with or believes matters when it comes to privacy options.
8. Next are some more personal choices, this time for
   1. If applicable and/or you wish, choosing to have Windows customized according to the use you expect to make if it (The author skips this because he doesn't fit in their nice check boxes).
   2. Choosing whether to link your phone to your PC (The author prefers to do that outside the wizard, so this is another options he skips).
   3. Choosing whether to back you files up to One Drive.  This likely only makes sense if you have a Microsoft 365 subscription or One Drive Premium as the free OneDrive doesn't have much storage, so this guide doesn't show making a choice here.
9. You will then get various 'please wait' variety messages as Windows is configured and set up.

## First steps, post install

[There's a page for that; Windows 10 Pro, first steps post-install](first-steps-post-install.md)
