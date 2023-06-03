+++
title = "Netlify pre-commit and other news"
slug = "netlify-pre-commit-and-other-news"
author = "Daniel F. Dickinson"
description = """\
Announcing `netlify-plugin-pre-commit` and some updates on my training and paid \
work opportunities. (They've come through!)\
"""
summary = """\
Announcing `netlify-plugin-pre-commit` and some updates on my training and paid \
work opportunities. (They've come through!)\
"""
date = 2023-05-26T01:05:30-04:00
publishDate = 2023-05-26T01:05:30-04:00
tags = [
	"hosting",
	"opinion",
	"sysadmin-devops",
	"web-design"
]
frontCard = true
card = true
toc = true
+++

## Preface

Announcing `netlify-plugin-pre-commit` and some updates on my training and paid
work opportunities. (They've come through!)

## A side project while ramping up 'real' work

I finally have an experimental pre-release of a software tool I have had on
my To Do list to create, for quite some time. I did it now, because
my time for such projects will soon be in short supply.

### Description of `pre-commit` plugin for Netlify

Speed up use of [pre-commit](https://www.pre-commit.com) with
[Netlify](https://www.netlify.com) (especially by caching hook installation).

### What that means

#### Some definitions

`pre-commit`
: A tool to make 'git hook scripts' easy. Git hook scripts are useful for
  identifying simple issues before submission. We run our hooks on every
  commit to automatically point out issues in code such as missing semicolons,
  trailing whitespace, and debug statements. This allows developers and
  reviewers to focus on the architecture of a change, not trivial style
  nitpicks. (Paraphrased from [Introduction \[_to
  pre-commit_\]](https://pre-commit.com/#introduction)).

Netlify
: An all-in-one platform which helps you combine your favorite tools
  and APIs to build the fastest sites (and more) for the composable
  web. Use any frontend framework (the author of this article uses
  [Hugo](https://gohugo.io)) to build, preview, and deploy to Netlify's
  global network from Git. (Paraphrased from [Welcome to
  Netlify](https://docs.netlify.com/)).

Git
: A [free and open
  source](https://git-scm.com/about/free-and-open-source) distributed
  version control system designed to handle everything from small to
  very large projects with speed and efficiency. (From [the Git SCM
  website](https://git-scm.com)).

#### The problem the plugin solves

When pushing a new update to stock Netlify (e.g. to website or blog)
and one verifies one's source files as part of building one's site on
Netlify using `pre-commit`, there one's site deployment takes significantly
longer than pushing without verification. The largest chunk of this time
is spent installing the software used by `pre-commit`.
`netlify-plugin-pre-commit` solves this issue by
[caching](https://en.wikipedia.org/wiki/Cache_(computing)) the software
used by the 'pre-commit hooks' in the cache provided by Netlify.

#### Additional features

The plugin also makes using `pre-commit` easier by 'auto-installing'
`pre-commit` and the hook software defined in `.pre-commit-config.yaml`, if
said file exists in the Git repository sent to Netlify. (One sends Git
repositories to Netlify so that it can process and deploy (e.g.)
websites/blogs on Netlify's 'cloud' servers).

### Where you can find `netlify-plugin-pre-commit`

#### As an NPM package (for Node.js)

This makes installation a breeze. See below.

<https://www.npmjs.com/package/netlify-plugin-pre-commit>

#### The source code on GitHub

<https://github.com/danielfdickinson/netlify-plugin-pre-commit>

## Using `netlify-plugin-pre-commit`

### Install

Currently this plugin can only be installed using [file-based
installation](https://docs.netlify.com/integrations/build-plugins/#file-based-installation).

### Example: add the following to your `netlify.toml` file

```toml
[[plugins]]
package = "netlify-plugin-pre-commit"
```

### And add the NPM package to your `package.json`

1. Change to the directory containing the Git repository for a website for
which you want to use the plugin.

2. If you have not already, execute `npm init` to create a new `package.json`

3. Execute the following command to add the plugin to the development
dependencies (software to include) for your website build.

   ```bash
   npm install --save-dev netlify-plugin-pre-commit
   ```

4. If you have not already, create the `pre-commit-config.yaml` for your
site. (See <https://pre-commit.com/#2-add-a-pre-commit-configuration>).

5. Now the plugin and `pre-commit` are enabled and will be used each time
you create a merge request against, or push to, your main (production)
branch.
