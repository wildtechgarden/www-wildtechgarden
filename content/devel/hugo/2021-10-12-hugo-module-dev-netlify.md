---
slug: hugo-module-dev-netlify
aliases:
    - /develop-design/web-design-web-devel/hugo-module-dev-netlify/
    - /docs/devel/hugo-module-dev-netlify/
    - /blog/hugo-module-dev-netlify/
title: "ARCHIVED: Hugo module devel on Netlify"
date: 2021-10-12T17:10:00-0400
publishDate: 2021-10-12T17:10:00-0400
author: Daniel F. Dickinson
tags:
    - frontend
    - devel
    - docs
    - projects
    - web-design
description: "Using a Hugo module starter and Netlify for Hugo module development"
summary: "Using a Hugo module starter and Netlify for Hugo module development"
---

A starter repo for building Hugo modules (by Daniel F. Dickinson)

## Status

ARCHIVED: This repo is no longer maintained and may have problems (including security issues) and may be out-of-date.

## GitHub Repo

<https://github.com/danielfdickinson/hugo-dfd-module-starter>

## Features

* Hugo module
* exampleSite (for demo deploys and/or documentation)
* Netlify-ready
  * Cache resources folder (exampleSite)
  * HTML Validation
  * Check internal links
  * HTML Minification
* Module Demo Site allows showing [Hugo Debug Tables](https://github.com/danielfdickinson/hugo-debug-tables) by setting ``debugTablesInFooter = true`` in the ``exampleSite/config.toml``.
* More…

## Not a Theme

**Note:** This is not a theme, or even a theme component (although it could be the basis for one).
This is a Hugo module skeleton, but with useful defaults for many of the files you will need in an
actual module.

## Using the Starter

### Create new repo for module

1. Download an archive of ``hugo-dfd-module-starter``.
   * Latest version of the ``main`` branch:
     * ZIP: <https://github.com/danielfdickinson/hugo-dfd-module-starter/archive/refs/heads/main.zip>
     * Tarball: <https://github.com/danielfdickinson/hugo-dfd-module-starter/archive/refs/heads/main.tar.gz>
   * Or the latest release (currently v0.4.0):
     * Tarball: <https://github.com/danielfdickinson/hugo-dfd-module-starter/archive/refs/tags/v0.4.0.tar.gz>
     * Or ZIP: <https://github.com/danielfdickinson/hugo-dfd-module-starter/archive/refs/tags/v0.4.0.zip>
2. Create a directory (for example ``hugo-dfd-responsive-images``)
3. ``cd hugo-dfd-responsive-images``
4. Extract the archive into this directory (note that the archive contains a top-level versioned directory that you don't want. For example the README would be in ``hugo-dfd-module-starter-v0.4.0/README.md`` and you want it in ``README.md`` in your current directory. If you are using the tarball on Linux (including WSL), you can do ``tar --strip-components=1 -xzf /path/to/your/source-archive.tar.gz``).
5. Edit ``README.md``, ``LICENSE``, ``go.mod``, ``netlify.toml``, ``exampleSite/config.toml``, ``exampleSite/content/about.md``, ``exampleSite/content/accessibility.md``, and ``exampleSite/content/docs/README.md``.
6. ``git init``
7. ``git checkout -b main`` (this is optional)
8. ``git branch -D master`` (only execute if you use 7. above)
9. (optional) ``git lfs install``
10. ``export HUGO_MODULE_REPLACEMENTS="github.com/danielfdickinson/hugo-dfd-module-starter -> $(pwd)"; cd exampleSite && hugo mod tidy`` (substituting your module name for ``github.com/danielfdickinson/hugo-dfd-module-starter``).
11. ``npm upgrade`` (this updates the Netlify plugins to latest versions, and fixes the ``package-lock.json`` current package name to your new module instead of ``hugo-dfd-module-starter``).
12. ``git add .``
13. ``git commit``
14. Create a GitHub repo (e.g. in one case, I used ``hugo-dfd-responsive-images`` which resulted in a URL of <https://github.com/danielfdickinson/hugo-dfd-responsive-images>) (do not add a README, LICENSE and so on via GitHub as the repo already has all that, and you want a bare repository to which to push your local repo).
15. ``git remote add origin https://github.com/danielfdickinson/hugo-dfd-responsive-images.git``
16. ``git push origin --set-upstream main``
17. After a few moments you should see the code for your repo on GitHub (in the web interface).

### Connect repo with Netlify (for CI)

Prerequisite: You have already setup the Netlify app for you GitHub user or organization and are either allowing Netlify access to all your repositories or you have allowed Netlify access to this repo.

1. Login to Netlify
2. Select 'New Site from Git'
3. Select 'GitHub'
4. Select this repository from the list
5. If you are using Git-LFS, Select 'Advanced' and add variable ``GIT_LFS_ENABLED`` with value ``1``.
6. Select 'Deploy Site'
7. If you want to watch deploy progress, right click over the deploy and select "open in new tab" in your browser.
   1. If the deploy was not successful, correct any errors, commit and push, which should trigger another attempt at deploying.
8. Once the deploy is successful, select 'Site Settings' and 'Domain Management'
9. Beside the default Netlify random-site-name.netlify.app name select 'Options' and 'Edit site name'.
10. Rename the site (will always end in .netlify.app).
11. If you want a custom domain name and have a DNS service other than Netlify, then sign on to you provider and set a CNAME from your new-domain-name.example.com to your-netlify-domain-name.netlify.app.
    1. Trigger a deploy (otherwise the old name will interfere with the new name)
    2. If you have Netlify DNS you can skip this step
    3. Select 'Add custom domain'
    4. Enter the custom domain name from above.
    5. Select add the domain.
    6. Under HTTPS select 'Verify DNS configuration'
    7. Select 'Provision certificate'
    8. Wait
    9. You should now have an SSL protect version of the demo site for you repo.
12. Tweak any other settings as you wish.

### (Optional) Set up 'branch protection'

1. On GitHub, for you repo, go to Settings|Branches and enable 'branch protection' (Add rule, and enter 'main' as the branch)
   1. Check 'Require status checks to pass before merging'
   2. Check 'Require branches to be up to date before merging'
   3. Select 'Require linear history'
   4. Select 'Include administrators'
   5. Select 'Create'
2. In your repo create a new pull request branch (can have any name).
3. In Netlify go to Site Setting and copy the 'Site Badge' code
4. Paste site badge code into your README
5. Save and commit the change.
6. Push the new pull request branch to GitHub
7. Create a new pull request from the branch on GitHub
8. Once the deploy preview succeeds, open a new tab for 'Settings|Branches'
9. Select 'Edit' on you current 'main' branch protection rule
10. Search for statuses using the name of your repo
    1. You want at least:
       1. netlify/your-repo/deploy-preview
    2. All but 'changed pages' is recommended
11. Click 'Save Changes'
12. Close that tab
13. Back on the Pull Request (PR), Select 'Squash and Merge'
14. Confirm 'squash and merge'
15. Delete branch
16. Back in Netlify check the deploy status; it should succeed
17. On GitHub check your repository's README; it should show a Netlify status of 'Success'

### Develop Your Module

You are now ready to develop your module.
Hack away!

## Some useful Markdown for your module's README

```markdown
## Features

TBD

## Basic Usage

### Importing the Module

1. The first step to making use of this module is to add it to your site or theme.  In your configuration file:

   ``config.toml``
   \```toml
   [module]
     [[module.imports]]
       path = "github.com/danielfdickinson/hugo-dfd-module-starter"
   \```
   OR
   ``config.yaml``
   \```yaml
   module:
     imports:
       - path: github.com/danielfdickinson/hugo-dfd-module-starter
   \```
2. Execute
   \```bash
   hugo mod get github.com/danielfdickinson/hugo-dfd-module-starter
   hugo mod tidy
   \```
```
