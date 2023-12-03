---
slug: using-xca-to-create-private-ssl-certificates
aliases:
    - /docs/sysadmin-devops/using-xca-to-create-private-ssl-certificates/
    - /sysadmin-devops/using-xca-to-create-private-ssl-certificates/
    - /deploy-admin/using-xca-to-create-private-ssl-certificates/
    - /docs/deploy-admin/sysadmin-devops/using-xca-to-create-private-ssl-certificates/
    - /deploy-admin/sysadmin-devops/using-xca-to-create-private-ssl-certificates/
title: "Using XCA to create private SSL certificates"
date: 2021-05-11T04:53:25-04:00
publishDate: 2021-05-12T22:44:03-04:00
tags:
- linux
- sysadmin-devops
summary: "This article details using the XCA GUI for creating private SSL certificates for enabling end-to-end SSL on non-public servers."
description: "This article details using the XCA GUI for creating private SSL certificates for enabling end-to-end SSL on non-public servers."
frontCard: true
card: true
---

{{< details-toc >}}

## Preface

This article details using the XCA (available for at least Linux, Windows, and MacOS for creating and managing SSL certificates) software package (it is a GUI) for creating private SSL certificates for enabling end-to-end SSL on non-public servers (e.g. where Let's Encrypt / Certbot don't make sense or are not an option).

## Obtain XCA

* Obtain XCA for your desktop computer (<https://hohnstaedt.de/xca/>)
  * Windows
    * <https://github.com/chris2511/xca/releases/download/RELEASE.2.3.0/xca-2.3.0.msi>
    * Chocolatey has an xca package
  * Mac
    * <https://github.com/chris2511/xca/releases/download/RELEASE.2.3.0/xca-2.3.0.dmg>
    * Probably available via homebrew
  * Linux
    * Check for a package in your package manager (Debian/Ubuntu-derivatives should have it available by ``sudo apt install -y xca`` for instance).
    * It is also available via Flathub (<https://flathub.org>) : ``flatpak install xca``
    * Otherwise try the generic tarball: <https://github.com/chris2511/xca/releases/download/RELEASE.2.3.0/xca-2.3.0.tar.gz>

## Launch XCA

* The usual way for your OS (e.g. on Windows, from the 'Start' Menu, on GNOME on Linux, click on the XCA icon in you 'Applications' screen, etc).
* This will open a window prompting for a database. If this is is to be a new certificate store (e.g. the first time using XCA or you want a separate store for new certificates) you should create one, otherwise select an existing database and enter the password for it.

## Create a self-signed CA (Certificate Authority)

**NB** Any application that will be using SSL to access a server using a certificate signed by this private CA will need to be told to trust the private CA. This varies with application, so where I use this in other articles, I provide instructions for the particular application in use.

1. {{< figure caption="Click on 'New Certificate' or press 'Alt-N'" src="/assets/images/xca-main-screen-new-certificate-highlighted.png" alt="main window with 'New Certificate circled" >}}
2. {{< figure caption="Near the bottom of the dialogue, under 'Template for new certificate', select '\[default] CA'" src="/assets/images/xca-new-certificate-dialogue-with-default-CA-selected.png" alt="screenshot of XCA new certificate dialogue with default CA circled" >}}
3. {{< figure caption="Click on 'Apply all'" src="/assets/images/xca-new-certificate-dialogue-with-apply-all-highlighted.png" alt="new certificate dialogue with 'Apply all' circled" >}}
4. {{< figure caption="Select the Subject tab and fill in the information as appropriate" alt="new certificate dialogue 'Subject' tab with example information entered" src="/assets/images/xca-new-certificate-dialogue-subject-tab-with-example-data.png" >}}
5. {{< figure caption="Click on  Generate a new key'" src="/assets/images/xca-newcertificate-dialogue-subject-tab-with-generate-key-circled.png" alt="new certificate dialogue subject tab with 'Generate a new key' circled" >}}
6. {{< figure caption="Click 'OK' or press 'Alt-O'" src="/assets/images/xca-new-certificate-dialogue-subject-tab-with-OK-circled.png" alt="new certificate dialogue subject tab with 'OK' circled" >}}

## Export the CA's public key (.crt)

1. {{< figure caption="Select the CA" src="/assets/images/xca-main-screen-with-ca-circled.png" alt="main screen with CA circled" >}}
2. {{< figure caption="Click 'Export' button" src="/assets/images/xca-main-screen-with-export-circled.png" alt="main screen with 'Export' button circled" >}}
3. {{< figure caption="Choose where to export CA (choose it's filename and location) (later we'll assume you called the file 'ca-private-net.crt' and you know where to find it)" src="/assets/images/xca-export-dialogue-with-filename-and-path-circled.png" alt="export dialogue with filename and path circled" >}}
4. {{< figure caption="Click the 'OK' button" src="/assets/images/xca-export-dialogue-with-ok-circled.png" alt="dialogue with OK button circled" >}}

## Create a server certificate and private key

1. {{< figure caption="Select the CA" src="/assets/images/xca-main-screen-with-ca-circled.png" alt="main screen with CA circled" >}}
2. {{< figure caption="Click on 'New Certificate' or press 'Alt-N'" src="/assets/images/xca-main-screen-new-certificate-highlighted.png" alt="main window with 'New Certificate circled" >}}
3. {{< figure caption="Make sure 'Use this Certificate for signing' is set to your CA" src="/assets/images/xca-new-certificate-dialogue-with-ca-selected-and-circled.png" alt="new certificate dialogue with an existing CA selected to use as the certificate for signing" >}}
4. {{< figure caption="In the 'Template for new certificate' drop down, select '\[default] TLS_server'" src="/assets/images/xca-new-certificate-dialogue-with-tls-server-template-selected.png" alt="new certificate with TLS server template selected and circled (and an existing CA selected to use for signing)" >}}
5. {{< figure caption="Select 'Click 'Apply all' button" src="/assets/images/xca-new-certificate-dialogue-with-ca-tls-server-selected-and-apply-all-circled.png" alt="new certificate dialogue with 'Apply all' circled when TLS template is selected, and with an existing CA selected for use" >}}
6. {{< figure caption="Select the Subject tab and fill in the information as appropriate. Note that the CN (common name) should be the primary DNS name of your server." src="/assets/images/xca-new-certificate-dialogue-subject-tab-with-server-information-filled-in.png" alt="new certificate dialogue for a server certificate, with subject fields filled in" >}}
7. {{< figure caption="Click 'Generate a new key' or press 'Alt-G'" src="/assets/images/xca-new-certificate-dialogue-subject-tab-with-server-information-filled-in-and-generate-new-key-circled.png" alt="certificate dialogue subject tab for a server certificate, with 'Generate a new key' circled" >}}
8. {{< figure caption="Select the Extensions tab, and select 'Edit' beside X509v3 Subject Alternative Name" src="/assets/images/xca-new-certificate-dialogue-for-server-extensions-page-with-SAN-edit-circled.png" alt="new certificate dialogue extensions tab with SAN (Subject Alternative Name) edit button circled" >}}
9. {{< figure caption="Select add and add a DNS name or IP besides the CN (common name). If there are no alternative names or IP addresses to be used, this can be left with only 'Copy Common Name' checked and no additional entries." src="/assets/images/xca-subject-alternate-name-dialogue-with-an-example-entry.png" alt="x509v3 SAN (Subject Alternative Name) dialogue with an example DNS entry" >}}
10. Repeat 'Add' in this dialogue for every name (DNS) or IP by which the server will be accessed using SSL. If there none besides the CN (Common Name) , then none need to be added.
11. {{< figure caption="Select 'Validate'. If there are issues, fix them." src="/assets/images/xca-san-dialogue-with-validate-circled.png" alt="x509v SAN dialogue with 'Validate' button circled" >}}
12. {{< figure caption="Click 'Apply'" src="/assets/images/xca-san-dialogue-with-apply-circled.png" alt="SAN dialogue with 'Apply' button circled" >}}
13. {{< figure caption="Select 'OK'" src="/assets/images/xca-new-certificate-dialogue-for-server-certificate-with-ok-circled.png" alt="new certificate dialogue for server certificate with 'OK' circled" >}}

## Export the server certificate and private key

### Export the server certificate

1. {{< figure caption="Select the new certificate (you will have to double-click on your CA first)" src="/assets/images/xca-main-screen-with-server-certificate-selected.png" alt="main dialogue with a CA-signed server certificate selected" >}}
2. Select, 'Export' and then use the same steps (with different names) as in [Export the CA's Public Key (.crt)](#export-the-cas-public-key-crt)

### Export the server private key

1. {{< figure caption="Select 'Private Keys' tab and select the private key associated with the certificate above" src="/assets/images/xca-private-keys-tab-with-tab-circled.png" alt="main screen with 'Private Keys' selected and circled and a private key circled" >}}
2. {{< figure caption="Click on 'Export' button" src="/assets/images/xca-private-keys-tab-with-export-circled.png" alt="private keys tab with 'Export' circled" >}}
3. {{< figure caption="Choose where to export (filename) (later we'll assume 'private-server.example.com.pem')" src="/assets/images/xca-export-private-key-dialogue-with-filename-circled.png" alt="export private key dialogue with filename circled" >}}
4. {{< figure caption="Select 'PEM private' (NB protect this file as it contains important security information; preferably securely erase any copies once it is in the needed location on the server)" src="/assets/images/xca-private-key-export-dialogue-with-pem-private-circled.png" alt="private key export dialogue with PEM private circled" >}}
5. {{< figure caption="Click 'OK' button" src="/assets/images/xca-export-private-key-dialogue-with-ok-circled.png" alt="export private key dialogue with 'OK' button circled" >}}

## Copy the exported files to your server and/or clients

* You will need to copy the at least the server private key and certificate to you server (details are application dependent so for articles on this site will be covered in the article for the application).
* Clients will need the CA certificate and possibly need to per-app configuration to use it. As with the server certificate and key, for articles on this site the details will be covered in the article for the application).

## Prepare your user clients to use SSL to the server

**NB** This is for certificates for web servers, git server, etc where a desktop user will need to access the server via SSL.

* Because we are using a private CA your browser and other desktop clients need to be told to trust the private CA.

1. On any Debian/Ubuntu workstation that needs to access the private CA, copy the private CA certificate (e.g. ``ca-private.example.com``) to ``/usr/local/share/ca-certificates`` and execute ``update-ca-certificates``
2. Also on any Debian/Ubuntu workstation for which Firefox needs to access the server:

   ```bash
   mkdir -p /etc/firefox/policies
   sudoedit /etc/firefox/policies/policies.json
   ```

   **Note**: Even when the main Firefox is an ESR release and uses `/etc/firefox-esr`,
   for adding policies (like installing certificates) it is necessary to use
   `/etc/firefox/policies/policies.json`.

   In ``policies.json`` add:

   ```json
   {
       "policies": {
           "Certificates": {
                "Install": [
                    "/usr/local/share/ca-certificates/ca-private.example.com.crt"
                ]
            }
        }
   }
   ```

3. On any Windows workstation that needs to access the private CA,
   1. Install the private CA into the system certificate store
      1. {{< figure src="/assets/images/install-ca-windows-install-certificate-circled.png" caption="Double-click on ``ca-private-example.com.crt``, select 'Install certificate' and click 'OK'" alt="Windows 10 install certificate dialogue" >}}
      2. {{< figure src="/assets/images/install-ca-windows-local-machine-and-next-circled.png" caption="For 'Store Location' select 'Local Machine' and click 'Next'.  You may be prompted for your administrative credentials." alt="Select 'Local Machine' in install certificate wizard" >}}
      3. {{< figure src="/assets/images/install-ca-windows-place-all-certificates-and-browse-circled.png" caption="Select 'Place all certificates in the following store' and click 'Browse...'" alt="Selection of location to install certificate in the install certificate wizard" >}}
      4. {{< figure src="/assets/images/install-ca-windows-trusted-root-certificate-authorities-circled.png" caption="Select 'Trusted Root Certification Authorities' and click 'OK'" alt="Selection of which system-wide store to use in the install certificate wizard" >}}
      5. {{< figure src="/assets/images/install-ca-windows-completing-the-certificate-import.png" caption="Confirm the details presented and click 'Finish'" alt="Confirmation page for install certificate wizard" >}}
   2. For making the CA available for recent Firefox system-wide:
      1. Create a directory called ``C:\\ProgramData\\FirefoxCertificates``
      2. Copy ``ca-private.example.com.crt`` to ``C:\\ProgramData\\FirefoxCertificates``
      3. Create a directory called ``distribution`` in ``C:\\Program Files\\Mozilla Firefox``, and in the ``distribution`` directory add a file called ``policies.json`` containing:

         ```json
         {
             "policies": {
                 "Certificates": {
                      "Install": [
                          "C:\\ProgramData\\FirefoxCertificates\\ca-private.example.com.crt"
                      ]
                 }
             }
         }
         ```

    See Also [Mozilla's Github Repository for Policy Templates](https://github.com/mozilla/policy-templates)
