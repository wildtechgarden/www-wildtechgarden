---
slug: hugo-on-netlify-with-wsl
aliases:
    - /sysadmin-devops/windows-and-linux/hugo-on-netlify-with-wsl/
    - /deploy-admin/hugo-on-netlify-with-wsl/
    - /docs/devel/hugo/hugo-on-netlify-with-wsl/
title: "Hugo on Netlify With WSL(2)"
date: 2021-11-04T21:34:42Z
publishDate: 2021-11-04T21:34:42Z
author: Daniel F. Dickinson
tags:
    - deploy
    - web-design
    - windows-and-linux
description: "A configuration for using Hugo on WSL(2) with Netlify and Netlify CLI"
summary: "A configuration for using Hugo on WSL(2) with Netlify and Netlify CLI"
card: true
---

## Setting Up Your WSL/WSL2 Environment

### Essentials

[Install WSL(2) for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install)

### Recommended

1. Create a ``~/.profile`` that adds a number of user-specific directories to your ``PATH``. This makes it easier to upgrade some software.
   ``.profile``

   ```bash
   # ~/.profile: executed by the command interpreter for login shells.
   # This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
   # exists.
   # see /usr/share/doc/bash/examples/startup-files for examples.
   # the files are located in the bash-doc package.

   # the default umask is set in /etc/profile; for setting the umask
   # for ssh logins, install and configure the libpam-umask package.
   #umask 022

   # if running bash
   if [ -n "$BASH_VERSION" ]; then
       # include .bashrc if it exists
       if [ -f "$HOME/.bashrc" ]; then
           . "$HOME/.bashrc"
       fi
   fi

   # set PATH so it includes user's npm-global/bin if it exists
   if [ -r "$HOME/.npmrc" ]; then
       if [ -d "$(npm bin -g 2>/dev/null)" ]; then
           PATH="$(npm bin -g 2>/dev/null):$PATH"
       fi
   fi

   # set PATH so it includes system newer Go, if it exists
   if [ -d "/usr/local/go/bin" ]; then
       PATH=/usr/local/go/bin:"${PATH}"
   fi

   # set PATH so it includes user Go bin, if it exists
   if [ -d "$HOME/go/bin" ]; then
      PATH="$HOME/go/bin:${PATH}"
   fi

   # set PATH so it includes user's private bin if it exists
   if [ -d "$HOME/bin" ] ; then
       PATH="$HOME/bin:$PATH"
   fi

   # set PATH so it includes user's private bin if it exists
   if [ -d "$HOME/.local/bin" ] ; then
       PATH="$HOME/.local/bin:$PATH"
   fi
   ```

2. Create an ``~/.npmrc`` file that makes your NPM globally installed packages local to your user (to avoid require ``sudo`` to ``root`` to install global NPM packages).
   ``.npmrc``

   ```plain
   prefix = /home/daniel/npm-global
   ```

3. Install [NodeSource's NodeJS package](https://github.com/nodesource/distributions/#installation-instructions)
4. ``sudo apt install git-core git-lfs``
5. Make sure [Git for Windows](https://git-scm.com/download/windows) is installed and usable by your *WIndows* user.
6. Create a ``~/.gitconfig`` such as the following (replacing ``name`` and ``email`` with your public name and email on GitHub or similar service). The commented sections may be uncommented if you are using [Visual Studio Code](https://code.visualstudio.com/):
   ``.gitconfig``

   ```ini
   [credential]
       helper = /mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe
   [core]
       fileMode = true
       eol = lf
       autocrlf = false
   #    editor = code --wait
   [user]
       name = Your Name
       email = 55555555+your-github-privacy-email-address@example.com
   [pull]
       ff = only
   [filter "lfs"]
       required = true
       clean = git-lfs clean -- %f
       smudge = git-lfs smudge -- %f
       process = git-lfs filter-process
   #[diff]
   #    tool = vscode
   #[difftool "vscode"]
   #    cmd = code --wait --diff $LOCAL $REMOTE
   #[merge]
   #    tool = vscode
   #[mergetool]
   #    cmd = code --wait $MERGED
   ```

7. If applicable to you, [configure Visual Studio Code to for use with WSL(2)](https://code.visualstudio.com/docs/remote/wsl),
8. If using *Windows Terminal* and the *Ubuntu-20.04* distribution, then in *Windows Terminal*'s Settings, set the startup directory to \\\\wsl\$\\Ubuntu-20.04\\home\\USERNAME (where USERNAME is your WSL(2) username, created during installation, above). For doing development using the WSL2 filesystem rather than the native Windows filesystem is preferred because when using Linux-native applications, accessing the WSL2 filesystem is much faster than accessing a Windows native filesystem.

### For Hugo Users

1. [Download and install the latest version of Go for your distribution](https://go.dev/doc/install)
   1. E.g. Download, then ``sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz``
   2. [Download the latest version of Hugo extended for your distribution](https://github.com/gohugoio/hugo/releases) and [install for your distribution](https://gohugo.io/getting-started/installing/).
   3. For Debian/Ubuntu distributions I recommend [Downloading the latest ``.deb`` for Hugo extended for your CPU architecture](https://github.com/gohugoio/hugo/releases) and using ``sudo dpkg -i <package-name>.deb``

### For Netlify Users

1. Install NodeJS (for NPM) as described above.
2. ``npm install netlify-cli -g``

### Optional

* Create ``~/bin`` and ``~/local/bin`` for adding ad-hoc binaries (programs) for your WSL(2) user
* ``ln -s /mnt/c/Users/WINDOWS_USERNAME ~/.wsl`` for easy access to the ``%USERPROFILE%`` directory of your Windows user (this is your Windows 'home' folder)

## Using Hugo with Netlify CLI with WSL/WSL2

* ~~The easiest way for building Hugo modules is to use a 'starter' repo such as \[DFD Hugo Module Starter]\(`https://github.com/danielfdickinson/hugo-dfd-module-starter`)~~ \[*AUTHOR's NOTE:* The module starter repository has been removed] and follow the instructions in [Hugo Module Development With Netlify](2021-10-12-hugo-module-dev-netlify.md).
* If you are building a site the steps are similar but you need to remove the references to ``exampleSite`` because the site is the project.

### A Summary of the Steps Involved for Starting from Scratch

Assuming you have setup such as the above:

1. ``hugo new site name-of-site``
2. Create an empty GitHub repo for your new site.
3. Using git within WSL (not Git for Windows but a version of git you have installed in WSL, e.g. using ``sudo apt install git-core git-lfs``), initialize the repo:
   1. ``cd name-of-site``
   2. ``git init``
   3. ``git branch -M main``
4. Add a theme.
5. Edit the ``config.toml`` for the site as needed, including any steps required by the theme you have chosen to use.
6. Add scripts for use with ``netlify.toml``
   ``_scripts/hugo_build``

   ```bash
   #!/bin/bash
   set -o pipefail

   HUGO_BUILD_URL="$1"

   # Should only occur using Netlify CLI
   if [ -z "HUGO_BUILD_URL" ]
   then
       HUGO_BUILD_URL="https://www.example.com/"
   fi

   shift

   ( set -o pipefail && cd themes/hugo-geekdoc && npm install --no-save && npx gulp default )

   HUGO_MINIFY_TDEWOLFF_HTML_KEEPCOMMENTS=true HUGO_ENABLEMISSINGTRANSLATIONPLACEHOLDERS=true hugo ${HUGO_BUILD_URL:+-b $HUGO_BUILD_URL} && grep -inorE "<\!-- raw HTML omitted -->|ZgotmplZ|hahahugo|\[i18n\]" public/; RET="$?"

   if [ "$RET" != "0" ]
   then
       hugo --gc ${HUGO_BUILD_URL:+-b $HUGO_BUILD_URL} --cleanDestinationDir "$@"; RET=$?
   else
       cd ..
   fi

   exit "$RET"
   ```

   ``_scripts/hugo-serve``

   ```bash
   #!/bin/bash

   ( set -o pipefail && cd themes/hugo-geekdoc && npm install --no-save && npx gulp default )

   HUGO_MINIFY_TDEWOLFF_HTML_KEEPCOMMENTS=true HUGO_ENABLEMISSINGTRANSLATIONPLACEHOLDERS=true hugo ${HUGO_BUILD_URL:+-b $HUGO_BUILD_URL} && grep -inorE "<\!-- raw HTML omitted -->|ZgotmplZ|hahahugo|\[i18n\]" public/; RET="$?"

   if [ "$RET" != "0" ]
   then
       hugo server --poll 700ms -b http://localhost:8888/ -w "$@"
   else
       cd ..
   fi

   exit 0
   ```

7. Add an appropriate ``netlify.toml`` (note that some suggested plugins are shown as commented sections; using them does require some additional steps, not discussed here):

   ```toml
   [build]
     publish = "public"
     command = "hugo"

   [build.environment]
     HUGO_VERSION = "0.89.0"
     TZ = "America/Toronto"
     # GIT_LFS_ENABLED = "1"
     # GIT_LFS_FETCH_INCLUDE = "*.jpg,*.png,*.jpeg,*.svg,*.gif,*.pdf,*.mp4,*.bmp,*.webp,*.ico"

   [context.production]
     command = "_scripts/hugo-build \"$URL\""

   [context.deploy-preview]
     command = "_scripts/hugo-build \"$DEPLOY_PRIME_URL\""

   [context.branch-deploy]
     command = "_scripts/hugo-build \"$DEPLOY_PRIME_URL\""

   [dev]
     command = "_scripts/hugo-serve"
     targetPort = 1313
     framework = "#custom"

   #[[plugins]]
   #  package = "netlify-plugin-hugo-cache-resources"
   #
   #[[plugins]]
   #  package = "netlify-plugin-html-validate"
   #
   #[[plugins]]
   #  package = "netlify-plugin-checklinks"
   #
   #    [plugins.inputs]
   #      checkExternal = false
   #      skipPatterns = [ "<link rel=\"alternate\" type=\"application/rss+xml\"", "<meta http-equiv=\"refresh\" content=\"0; url=", "<meta property=\"og:url\" content=\"", "<meta property=\"og:image\" content=\"" ]
   #
   #[[plugins]]
   #  package = "netlify-plugin-minify-html"
   #
   #    [plugins.inputs.minifierOptions]
   #    collapseBooleanAttributes = true
   #    decodeEntities = true
   #    preserveLineBreaks = true
   #    removeAttributeQuotes = false
   #    removeComments = true
   #    removeEmptyAttributes = true
   #    removeOptionalTags = false
   #    removeRedundantAttributes = true
   #    removeScriptTypeAttributes = true
   #    removeTypeLinkTypeAttributes = true
   #    useShortDocType = false
   ```

8. Add some content
9. Use ``netlify dev`` to preview the site (and do a test build using the Hugo you installed in your WSL environment). Make sure the site skeleton works.
10. ``git add .``
11. ``git commit``
12. ``git remote add origin https://github.com/your-github-username/name-of-site``
13. ``git push origin --set-upstream main``
14. Your code should now be in GitHub.
15. [Connect repo with Netlify](2021-10-12-hugo-module-dev-netlify.md#connect-repo-with-netlify-for-ci).
16. Add content now and over time.
17. As you do, you can now use ``netlify build --context=deploy-preview`` and ``netlify build --context=production`` to verify builds will succeed without using build minutes until you have fixed any errors and get success builds using those commands.
