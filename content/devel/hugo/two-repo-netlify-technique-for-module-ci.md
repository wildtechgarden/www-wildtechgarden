+++
title = "Two-repo Netlify technique for module CI"
author = "Daniel F. Dickinson"
description = """\
Having a demo/test site embedded in a Hugo module causes large bandwidth \
consumption when the module is pulled by git during its normal use as a module.\
"""
summary = """\
Having a demo/test site embedded in a Hugo module causes large bandwidth consumption \
during its normal use as a module. We split the site and module into separate git \
repos, but keep a deploy as part of the CI process.\
"""
date = 2023-04-02T16:17:25-04:00
publishDate = 2023-04-02T16:17:25-04:00
tags = [
    "devel",
    "howtos",
    "web-design"
]
frontCard = true
card = true
toc = true
+++

## Preface

I recently discovered that [my Hugo module for responsive
images](https://github.com/danielfdickinson/image-handling-mod-hugo-dfd)
was causing a great deal of bandwidth usage. This is because I had the
demo/test site (including images) as a subdirectory in the module itself.
To resolve this, I now have the test/demo site in a separate git repository
that is only used for CI and deploying the site. The the module
repository is now much smaller and only pulls the demo repository during
CI.

Getting there wasn't as easy as I would have liked, so I describe the
process, and the resulting configuration, in this article.

### Prerequisites

This guide assumes the use of Netlify for CI site deployment and GitHub
as the hosting service for the module and demo/test site repos. If you are
using other providers you will need to adjust accordingly.

## Moving the large files out of the module

### Make a copy of the test site, elsewhere

This is the easy part; simply use your normal OS copy operation
to make sure you have a copy of all the files for your test site
in a safe location (outside the repo you will be shrinking).

This is important because later in the process we will remove the
files not only from the working tree, but from the history of the
repository as well. This means that the files cannot be restored
using Git.

### Make a list of any LFS files you wish to remove

Before you remove the LFS files you will need to make list of
objects using a command such as:

```bash
git lfs ls-files --all --long
```

### Remove references to unwanted files from CI

If your CI is GitHub workflows, this easiest way to achieve this is to
move your `.github/workflows` folder to `.github-disabled/disabled-workflows`.

Once you commit and push that change, the workflows will not run for this
repository. You will want to edit the workflows to adjust them to the new
way of doing things, once you have removed the problem files.

### Remove unwanted files and references to them

1. Now you need to `git rm -f` and/or `git rm -rf` any unwanted files.
2. Then you need to edit any files that reference the removed files (as they
will no longer be accessible) and commit the cleaned files.

### Obliterate the large files

In order to prevent `git clone` or Hugo modules (which use Go modules which in
turn uses git clone) from pulling large amounts of data we need to completely
remove the files, which means we have two choices:

1. Start over fresh with only the data we want.  
    1. This results in the loss of history
    2. This is easier to do.
    3. It may also be less confusing for users of your repository.
    4. It may be hard to get your users to switch to the new repository.
2. Rewrite history to remove any reference to the large files
    1. Preserves history for the files you keep.
    2. Some consider rewriting history an
    'Ultimate Evil{{< sup >}}TM{{< /sup >}}'
    3. Others with branches of you repository will need to rebase
       **not** merge.
    4. It takes more work.

I chose option two because I wanted to preserve as much history as
possible, while still achieving my goal.

#### Use git-filter-repo or similar tool

<https://github.com/newren/git-filter-repo>

<https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository>

#### For LFS, have the remote admin remove the LFS files

<https://docs.github.com/en/repositories/working-with-files/managing-large-files/removing-files-from-git-large-file-storage#git-lfs-objects-in-your-repository>

Note: you need to remove the files from you local repository and push that
first (per `git-filter-repo` or similar tool).

On GitHub, one would send the list of objects one generated to GitHub Support
and ask them to remove the listed objects.

## Create a new Hugo module repo with the site

Remember the copy of the test/demo site you made? Now you need to create a
Hugo module repository that contains the site (in the root of the repo, not a
subdirectory).

While this is out of scope for this article, it is just a standard Hugo site
creation exercise.

Note that while we will use Netlify for the original module's CI, one could
deploy the demo/test site elsewhere and using other tools. The important thing
is that the site is able to be pulled as Hugo a module by another Hugo module.
(See [Hugo's module documentation](https://gohugo.io/hugo-modules/)).

### Make sure the main module repository still works

Using your demo/test site which relies on the module from which your removed
the site, update the site's config to pull the 'module under test', and verify
the site builds.

Once the site is building and the module is working correctly, you can
implement CI for that module, using Netlify.

## Use a subdirectory of the module as a 'site'

The only file you need to add to the subdirectory is the
site's `config.toml` or `hugo.toml` (for very recent releases
of Hugo, only). The files `go.mod` and `go.sum` will be added by
the procedure below.

I use the name `exampleSite` for the subdirectory, and will use that in this
documentation.

### Add a site config in a subdirectory of the module

The 'magic' section of an example `exampleSite/config.toml` is:

```toml
[module]

[[module.mounts]]
source = "../static"
target = "static"

[[module.mounts]]
source = "../layouts"
target = "layouts"

[[module.mounts]]
source = "../README.md"
target = "assets/README-dfd-image-handling.md"

[[module.mounts]]
source = "../LICENSE"
target = "static/LICENSE"

[[module.mounts]]
source = "../ACKNOWLEDGEMENTS.md"
target = "content/post/ACKNOWLEDGEMENTS.md"

[[module.mounts]]
source = "../README-NOTES.md"
target = "content/post/README-NOTES.md"

[[module.mounts]]
source = "../i18n"
target = "i18n"

[[module.imports]]
path = "github.com/danielfdickinson/image-handling-mod-demo"
ignoreConfig = true
ignoreImports = true

[[module.imports.mounts]]
source = "static"
target = "static"

[[module.imports.mounts]]
source = "layouts"
target = "layouts"

[[module.imports.mounts]]
source = "data"
target = "data"

[[module.imports.mounts]]
source = "assets"
target = "assets"

[[module.imports.mounts]]
source = "i18n"
target = "i18n"

[[module.imports.mounts]]
source = "archetypes"
target = "archetypes"

[[module.imports.mounts]]
source = "content"
target = "content"

[[module.imports.mounts]]
source = "README-assets"
target = "assets/README-assets"

[[module.imports]]
path = "github.com/danielfdickinson/minimal-test-theme-hugo-dfd"
ignoreConfig = true
ignoreImports = true

[[module.imports.mounts]]
source = "static"
target = "static"

[[module.imports.mounts]]
source = "layouts"
target = "layouts"

[[module.imports.mounts]]
source = "data"
target = "data"

[[module.imports.mounts]]
source = "assets"
target = "assets"

[[module.imports.mounts]]
source = "i18n"
target = "i18n"

[[module.imports.mounts]]
source = "archetypes"
target = "archetypes"

[[module.imports]]
path = "github.com/danielfdickinson/link-handling-mod-hugo-dfd"
```

Note the use of relative paths such as `../layouts`. This is how
we make the module itself available to the 'site' that exists as a
subdirectory of the module.

Also note the lines

```toml
[[module.imports]]
path = "github.com/danielfdickinson/image-handling-mod-demo"
ignoreConfig = true
ignoreImports = true

[[module.imports.mounts]]
source = "static"
target = "static"

[[module.imports.mounts]]
source = "layouts"
target = "layouts"

[[module.imports.mounts]]
source = "data"
target = "data"

[[module.imports.mounts]]
source = "assets"
target = "assets"

[[module.imports.mounts]]
source = "i18n"
target = "i18n"

[[module.imports.mounts]]
source = "archetypes"
target = "archetypes"

[[module.imports.mounts]]
source = "content"
target = "content"
```

That pulls in the demo/test site (which was created as a module) and makes
it available to the build.

### Initialize `exampleSite` as a Hugo module

For example

```bash
hugo mod init github.com/danielfdickinson/image-handling-mod-hugo-dfd/exampleSite
```

### Activate any modules from the `config.toml`

You will need to be pulling in at least the demo/test site module.

```bash
hugo mod tidy
```

### Test with the Hugo local server

Make sure you are in your project root (e.g. the directory containing the
`exampleSite` subdirectory), then issue the following command:

```bash
hugo serve --source exampleSite --config config.toml
```

You should now be able to browse to `https://localhost:1313/` on same
host as where you ran that command and see the demo/test site against
the most current version of your module.

## Create a build script for use with Netlify

For example save the following as `scripts/netlify_build.sh` in your repo:

```bash
#!/bin/bash

set -e
set -o pipefail

## Commented out lines are additional validation
## you may wish to add (out of scope for article)

# pip install pre-commit

# pre-commit install --install-hooks
# pre-commit run --all-files

# bash ./tests/scripts/hugo-audit.sh
# rm -rf public exampleSite/public

## The following is only relevant if you use `site.Params.deployedbaseurl`
## for some purpose, in a template.

# if [ "$CONTEXT" = "production" ]; then
#     export HUGO_PARAMS_DEPLOYEDBASEURL="$URL"
# else
#     export HUGO_PARAMS_DEPLOYEDBASEURL="$DEPLOY_PRIME_URL"
# fi

HUGO_RESOURCEDIR="$(pwd)/resources" hugo --gc --minify -b $URL --source exampleSite --destination $(pwd)/public --config config.toml
```

## Deploy on Netlify

Follow one of Netlify's guides, such as
<https://docs.netlify.com/welcome/add-new-site/#import-from-an-existing-repository>
to create the initial CI version of the demo/test site. Note that the
repo to add is the module from which you removed demo site, not the demo site
repo.

Make sure you use the above script in your build command.

Build command:

```bash
bash scripts/netlify_build.sh
```

Also set `HUGO_VERSION` environment variable on Netlify to the same version of
Hugo as you use for your local testing.

The initial deploy will likely fail because on initial import `HUGO_VERSION`
is not honoured.

All you need to do is trigger the deploy again. The resulting build will use
the `HUGO_VERSION` you specified.

## Set your GitHub branch protection rules to require successful deploy

By requiring the Netlify status checks that will now be available in your
branch protection settings, you can require that the Netlify build be
successful before merging is allowed.

{{< figure src="assets/images/github-branch-protection-require-netlify-deploy-success.png" caption="Screenshot showing GitHub branch protection for 'main' branch which requires Netlify deploy-preview to succeed" alt="Screenshot showing GitHub branch protection for 'main' branch which requires Netlify deploy-preview to succeed" >}}

## Remember to `git rebase` not `git merge` or `git pull` any existing branches

If you (or those who have forked your repository) have existing branches with
the old version of your repo (including `main`), you will need to use

```bash
git checkout <branch>
git fetch <remote> <branch>
git rebase <remote>/branch
```

and **not**

```bash
git checkout <branch>
git pull <remote> <branch>
```

**nor** this

```bash
git checkout <branch>
git fetch <remote> <branch>
git merge <remote>/<branch>
```

Once the branch is using the rewritten version, however, one can use the
usual commands.

## Conclusion

As you can see there is a 'bit' of a process to removing a large demo/test
site from a module and replacing that with a separate CI deployment for the
module versus the demo/test site main deployment, but it is achievable.

Finally, if you want to see a pair of public repositories where I have
implemented this, you may view:

[image-handling-mod-hugo-dfd](https://github.com/danielfdickinson/image-handling-mod-hugo-dfd)  
and  
[image-handling-mod-demo](https://github.com/danielfdickinson/image-handling-mod-demo)

which are deployed as

<https://image-handling-mod-ci.demo.wildtechgarden.com>  
and  
<https://image-handling-mod.demo.wildtechgarden.com>

respectively.

Good luck!
