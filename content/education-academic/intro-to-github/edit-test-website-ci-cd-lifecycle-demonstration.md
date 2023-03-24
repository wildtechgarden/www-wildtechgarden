---
slug: edit-test-website-ci-cd-lifecycle-demonstration
aliases:
    - /29/edit-test-website-ci-cd-lifecycle-demonstration/
    - /2020/08/29/edit-test-website-ci-cd-lifecycle-demonstration/
    - /post/edit-test-website-ci-cd-lifecycle-demonstration/
    - /edit-test-website-ci-cd-lifecycle-demonstration/
    - /docs/development/git-github-gitea/introduction-to-git-and-github/edit-test-website-ci-cd-lifecycle-demonstration/
    - /develop-design/intro-to-github/29/edit-test-website-ci-cd-lifecycle-demonstration/
    - /develop-design/intro-to-github/edit-test-website-ci-cd-lifecycle-demonstration/
    - /devel/intro-to-github/edit-test-website-ci-cd-lifecycle-demonstration/
    - /intro-to-github/edit-test-website-ci-cd-lifecycle/
    - /post/intro-to-github/edit-test-website-ci-cd-lifecycle/
    - /posts/intro-to-github/edit-test-website-ci-cd-lifecycle/
    - /docs/education-academic/intro-to-github/edit-test-website-ci-cd-lifecycle-demonstration/
author: Daniel F. Dickinson
date: '2021-03-08T09:49:08+00:00'
publishDate: '2020-08-29T19:40:00+00:00'
tags:
- git
- sysadmin-devops
- web-design
title: Edit-test-website CI/CD lifecycle demo
description: "Example of a Netlify-based website CI/CD lifecycle on GitHub"
---

## Tools Used

* For this demonstration we show the use of [Visual Studio Code](https://code.visualstudio.com/)
* We also use [GitHub](https://github.com)
* And [Netlify](https://www.netlify.com)

## Before Website

{{< figure alt="screenshot of website before pushing commit" caption="screenshot of website before pushing commit" src="/assets/images/ci-cd-netlify-0-1-1024x676.png" >}}

## Creating a Commit

### Create a Branch

Not shown here, but you should create a separate branch to create a pull
request.

### Edit the Post

{{< figure alt="screenshot of a post in Visual Studio Code with the text to be deleted highlighted" caption="screenshot of a post in Visual Studio Code with the text to be deleted highlighted" src="/assets/images/ci-cd-netlify-01-1.png" >}}

### Stage Your Changes

Not shown here, but you should ‘stage’ the changes you want to commit.

### Add a Commit Message

{{< figure alt="screenshot of adding a commit message in Visual Studio Code" caption="screenshot of adding a commit message in Visual Studio Code" src="/assets/images/ci-cd-netlify-06-1.png" >}}

### Commit

{{< figure alt="screenshot after pressing 'Ctrl-Enter' to create the commit" caption="screenshot after pressing 'Ctrl-Enter' to create the commit" src="/assets/images/ci-cd-netlify-07-1.png" >}}

## Create a Pull Request

### Push the Commit to GitHub

{{< figure alt="screenshot showing push on popup menu" caption="screenshot showing push on popup menu" src="/assets/images/ci-cd-netlify-10-1-1024x676.png" >}}

#### If Applicable Select the GitHub ‘Remote’

For most beginners this will be ‘origin’.

{{< figure alt="screenshot of selecting a remote" caption="screenshot of selecting a remote" src="/assets/images/ci-cd-netlify-11-1-1024x676.png" >}}

### From the Branch Create a Pull Request

#### Go to GitHub and Select Compare & Pull Request

{{< figure alt="screenshot of creating a pull request" caption="screenshot of creating a pull request" src="/assets/images/ci-cd-netlify-13-1-1024x676.png" >}}

#### Update the Pull Request Title (If More than One Commit)

{{< figure alt="screenshot of setting the pull request title" caption="screenshot of setting the pull request title" src="/assets/images/ci-cd-netlify-15-2.png" >}}

#### Actually Create the Pull Request

Screenshot is from another PR

{{< figure alt="screenshot creating the pull request" caption="screenshot creating the pull request" src="/assets/images/ci-cd-netlify-49-1-1024x676.png" >}}

#### Wait for CI Checks to Complete

{{< figure alt="screenshot of unfinished CI checks" caption="screenshot of unfinished CI checks" src="/assets/images/ci-cd-netlify-18-1-1024x676.png" >}}

## Make sure the Continuous Integration Tests Succeeded

### Review the Test Results in GitHub

{{< figure alt="screenshot of completed CI checks" caption="screenshot of completed CI checks" src="/assets/images/ci-cd-netlify-19-1-1024x676.png" >}}

### Review the Preview Deploy (Netlify)

Sample preview is from a different PR

{{< figure alt="reviewing a preview deploy on Netlify — note the URL" caption="reviewing a preview deploy on Netlify — note the URL" src="/assets/images/ci-cd-netlify-54-1-1024x676.png" >}}

## Take the Changes Live

### Merge the Pull Request

{{< figure alt="screenshot of merging pull request" caption="screenshot of merging pull request" src="/assets/images/ci-cd-netlify-49-1-1024x676.png" >}}

### Verify (Once CI Tests Complete) The Site Has Been Updated

{{< figure alt="screenshot of new post blurb on front page of live site" caption="screenshot of new post blurb on front page of live site" src="/assets/images/ci-cd-netlify-24-1-1024x676.png" >}}

## Cleanup on GitHub

### Delete the PR Branch

{{< figure alt="screenshot of deleting PR branch" caption="screenshot of deleting PR branch" src="/assets/images/ci-cd-netlify-57-1-1024x676.png" >}}

## Merge the Changes Back to Your Local Repository

### Pull the Changes from GitHub

Screenshot from another PR

{{< figure alt="screenshot of pull from remote git" caption="screenshot of pull from remote git" src="/assets/images/github-operations-35-1-1024x676.png" >}}

### Fetch with Prune (Cleans Copy of the GitHub Branches)

Screenshot from another PR

{{< figure alt="screenshot of fetch with prune from remote git" caption="screenshot of fetch with prune from remote git" src="/assets/images/github-operations-25-1-1024x676.png" >}}

## Cleanup

### Delete Your Local Copy of the PR Branch

Screenshot from another PR

{{< figure alt="screenshot of deleting local branch" caption="screenshot of deleting local branch" src="/assets/images/github-operations-31-1-1024x676.png" >}}

### Verify the Git History

Screenshot from another PR

{{< figure alt="screenshot of git history" caption="screenshot of git history" src="/assets/images/github-operations-49-1-1024x676.png" >}}

## After Website

And the final result is post is live on your website and your local repo is in
sync with GitHub.

{{< figure alt="screenshot of new post blurb on front page of live site" caption="screenshot of new post blurb on front page of live site" src="/assets/images/ci-cd-netlify-24-1-1024x676.png" >}}
