---
slug: intro-to-github
aliases:
    - /29/introduction-to-git-and-github/
    - /2020/08/29/introduction-to-git-and-github/
    - /post/introduction-to-git-and-github/
    - /posts/introduction-to-git-and-github/
    - /introduction-to-git-and-github/
    - /docs/development/git-github-gitea/introduction-to-git-and-github/
    - /docs/development/git-github-gitea/intro-to-github/
    - /develop-design/intro-to-github/
    - /devel/intro-to-github/
    - /develop-design/29/introduction-to-git-and-github/
    - /docs/education-academic/intro-to-github/
    - /education-academic/intro-to-github/introduction-to-git-and-github/
author: Daniel F. Dickinson
date: 2021-03-08T09:46:40+00:00
publishDate: 2020-08-29T17:32:00+00:00
description: An Introduction to Git & GitHub based on a presentation I created for
  a group of fellow Makers at the MakerPlace at the Midland Public Library
tags:
- git
- sysadmin-devops
- web-design
title: Intro to Git and GitHub
showChildPages: false
---

{{< details-toc >}}

## Overview

Git is used extensively worldwide for many type of software and internet and other types of publishing projects (among others). This article provides an introduction to Git and probably the most popular central git repository ([GitHub](https://github.com)).

## Some Publishing Notes

These pages are based on a presentation I created for a group of fellow Makers at the [MakerPlace](https://midlandlibrary.com/the-mpl-makerplace/) at the [Midland Public Library](https://midlandlibrary.com/) in [Midland, Ontario](https://www.midland.ca/en/index.aspx). It is based on, but not a conversion of, a PowerPoint presentation. It would have taken as much work, or more, to convert what I used for the live presentation as I would need to add captions and narration to the videos (which in a web form are easily divided into screenshots with explanations) to satisfy my desire for an accessible website. In addition simply exporting a presentation to HTML5 tends not to be as browser agnostic as I would want.

## Version Control and Beyond

### Git Ecosystem (Where Git is Used and Why)

#### Git is Everywhere

{{< img alt="Shading map of world with GitHub users and commits by country" caption="Shading map of world with GitHub users and commits by country _Image author_: Stefano De Sabbata, license: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)" src="/assets/images/github-use-by-country-1.png" >}}Shading map of world with GitHub users and commits by country" caption="Shading map of world with GitHub users and commits by country _Image author_: Stefano De Sabbata, license: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

#### Why Git is Used

* Used / created for Linux kernel development
* The base technology is both _gratis_ and _libre_
* Version control and Source Code Management (Managing collaboration)
* Readily available cross-platform tools
* Distributed — users have their own copy
* Normally only changes are pushed or pulled to the ‘remotes’
* Developers are able to modify / enhance Git (as it is open source).
* Fast and light
* Easy branching and merging

#### Types of Projects (Sample)

* Linux and Cross-Platform Software (Open Source)
  * Linux Kernel, XOrg/Wayland, linux-utils, and Embedded Devices (OpenWrt)
  * Inkscape, GIMP, LibreOffice, Zim, KeepassXC, VSCode, …
* Web Applications (Open Source & Proprietary)
  * Many are based on the Python, Node.js, Ruby, or Golang ecosystems which mostly use Git
* DevOps / IaaS (Infrastructure as a Service); Often In-house
  * CircleCI, TravisCI, Jenkins and so on are all oriented towards git-based Continuous Integration and Continuous Deployment
  * Packer, Terraform, Ansible, Puppet, and Chef all aim to make infrastructure configuration a form of software
* Websites, and Documents
  * Netlify has become very popular for static website generation and publishing; others uses Hugo with old-school deployments or GH Pages
  * The Raspberry Pi Curriculum, Awesome Lists, and Open Source Software documentation projects all use Git for collaborating on documents

### Why Use Either GitHub or Their Competition

* Git emphasizes collaboration and sharing; central git makes it easy
* Central git services promote Continuous Integration (CI) and Continuous Deployment (CD)
* Allows both public and private repositories hosted on ‘cloud’ servers* Usually have many integrations with other development and project management tools.
* Other developers are more likely to find your project.
* In short they make life easier, especially when collaborating
* GitHub is the best known central git service
* Another two major central git services are: [GitLab](https://about.gitlab.com/) and [Bitbucket](https://bitbucket.org)

### Sign-up is Easy

Just got to <https://github.com> fill out the form, click ‘Sign Up’ and follow the prompts.

### GitHub Provides Learning Materials

{{< img alt="screenshot of GitHub welcome screen after sign-up" caption="screenshot of GitHub welcome screen after sign-up" src="/assets/images/github-welcome-choices-1-1024x622.png" >}}screenshot of GitHub welcome screen after sign-up
{{< img alt="screenshot of GitHub course choices if you go to 'GitHub Learning'" caption="screenshot of GitHub course choices if you go to 'GitHub Learning'" src="/assets/images/github-course-choices-1-1024x622.png" >}}screenshot of GitHub course choices if you go to 'GitHub Learning'

## Demonstration

[Edit, test, website (CI/CD) cycle](edit-test-website-ci-cd-lifecycle-demonstration)

## Git and Visual Studio Code Setup on Windows

### Setup Overview

* Install Chocolatey – this makes the rest of the installation easier and has added benefits
* Install “Git for Windows”, “Git Credential Manager for Windows”, and Visual Studio Code
* Configure “Git for Windows” & “Git Credential Manager for Windows”
* Add Extensions for Visual Studio Code
* Configure Visual Studio Code
* Test with provided tutorials.

### Install Chocolatey

Chocolatey is software that makes it easy to install other software (and remove or update the software you install). If in doubt, check the official install guide at <https://chocolatey.org/install>

1. Execute the following in a Administrator PowerShell terminal (right click the start menu icon and select “Windows PowerShell (Admin)”, if you are using Windows 10):

    ```powershell
    Set-ExecutionPolicy AllSigned -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    ```

2. Exit the PowerShell terminal
3. Launch another Administrator PowerShell terminal
4. Execute:

   ```powershell
   choco install chocolateygui
   ```

   This will give you a graphical interface for using Chocolatey

### Install Visual Studio Code, Git for Windows, and Git Credential Manager

1. In an Administrator PowerShell terminal
Execute ``choco install –y vscode git git-credential-manager``

### Configure Git for Windows (Recommendations)

Execute the commands in a regular PowerShell or Command Prompt

| Command                                                            | Why                                                                                                                                                                                          |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ``git config --global credential.helper = manager``                | Use Git Credential Manager for Windows                                                                                                                                                       |
| ``git config --global core.filemode = false``                      | Ignore permissions changes due to Windows filesystem                                                                                                                                         |
| ``git config --global core.autocrlf = true``                       | Use Windows line-endings when checking out, and convert the line-endings to Unix-style endings on commit                                                                                     |
| ``git config --global pull.ff = only``                             | Only “fast-forward” pulls (that means the branch you are pulling into won’t be altered, except the addition of new commits when you pull; you can still “git fetch” and merge if necessary). |
| ``git config --global core.editor = “code --wait"``                | "Use “Visual Studio Code” as default editor instead of vim or nano (which are harder for beginners to use)                                                                                   |
| ``git config --global user.name = “Your Name”``                    | Default user information (name) for commits                                                                                                                                                  |
| ``git config --global user.email = “yourgithubemail@example.net”`` | Default user information (email) for commits                                                                                                                                                 |

### Install Extensions for Visual Studio Code (Recommendations)

1. Execute the commands in a regular PowerShell or Command Prompt
| Command                                                        | Why                                                          |
| -------------------------------------------------------------- | ------------------------------------------------------------ |
| ``code --install-extension eamodio.gitlens``                   | GitLens is a useful set of enhancements for working with Git |
| ``code --install-extension GitHub.vscode-pull-request-github`` | Manage Pull Requests from within Visual Studio Code          |
| ``code --install-extension donjayamanne.githistory``           | View Git History and manage a git repo in Visual Studio Code |

1. Or you can install them using the GUI after launching Visual Studio Code.

## Learn and Use Visual Studio Code

1. Next you want launch Visual Studio Code, and read the ‘Welcome’ screen and follow the links that suit what you need to learn.
2. Check out [Working with GitHub](https://code.visualstudio.com/docs/sourcecontrol/github) on the Visual Studio Code website.

## Learn and Use Git

To borrow from the Visual Studio Code documentation: If you are new to Git, the [git-scm](https://git-scm.com/doc) website is a good place to start with a popular online [book](https://git-scm.com/book), [Getting Started videos](https://git-scm.com/videos) and [cheat sheets](https://training.github.com/downloads/github-git-cheat-sheet.pdf).

The VS Code documentation assumes you are already familiar with Git.
