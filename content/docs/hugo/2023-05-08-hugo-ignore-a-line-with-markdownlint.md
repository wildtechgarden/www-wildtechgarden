+++
title = "Hugo: Ignore a line with markdownlint"
slug = "hugo-ignore-a-line-with-markdownlint"
author = "Daniel F. Dickinson"
description = """\
When using `markdownlint-cli/markdownlint-cli2` or the `vscode-markdownlint` \
extension for VSCode, one may wish to ignore a particular line. Here is a \
cheap way to do that using a shortcode.\
"""
summary = """\
When using `markdownlint-cli/markdownlint-cli2` or the `vscode-markdownlint` \
extension for VSCode, one may wish to ignore a particular line. Here is a \
cheap way to do that using a shortcode.\
"""
date = 2023-05-08T21:15:27-04:00
publishDate = 2023-05-08T21:15:27-04:00
tags = [
	"web-design"
]
pageCanonical = false
toCanonical = "https://discourse.gohugo.io/t/ignore-a-line-with-markdownlint/44269"
frontCard = false
card = true
toc = true
aliases = [
	"/devel/hugo/hugo-ignore-a-line-with-markdownlint"
]
+++

## Overview

When using `markdownlint-cli/markdownlint-cli2` or the `vscode-markdownlint` extension for VSCode, one may wish to ignore a particular line. Here is a cheap way to do that using a shortcode.

## As `layouts/shortcodes/mdl-disable.html`

```golang
{{- /* Ignore the shortcode */ -}}
```

## In your Markdown

(where `img` below is a shortcode like `figure` except correctly validates when inside a paragraph (`<p>`) tag by only being an `<img>` tag).

```golang
{{</* img link="https://www.istockphoto.com/" src="https://media.istockphoto.com/photos/young-woman-watches-sunrise-outside-camping-tent-picture-id1248575497?s=612x612" height="50" alt="young woman watches sunrise outside camping tent" */>}} {{</* mdl-disable "<!-- markdownlint-disable MD034 -->" */>}}
```

This will disable the `MD034` check (`no-bare-urls`) for both the `vscode-markdownlint` extension (that is, the live linting while in VSCode) and when using `markdownlint-cli`, or `markdownlint-cli2`, possibly through [pre-commit](https://pre-commit.com) (but that is not required).

## Why we do it this way

1. `{{</*/*<!-- markdownlint-disable MD034 -->*/*/>}}` leaves the wrappers in the output page (see https://discourse.gohugo.io/t/how-to-comment-out-shortcodes-in-markdown/14893)
2. `{{</* mdl-disable "MD034" */>}}` with a shortcode that produced `<!-- markdownlint-disable MD034 -->` would only disable the linting checks on the output, not on the source Markdown files. This isn't terribly helpful.
3. We don't really want this shortcode in the output, we just want the Markdown source linters to see the 'magic' comment and ignore the line.

## Conclusion

It's a pretty easy once one figures it out. I hope it helps someone.

## Alternative

If you are the only one creating content/code in the repo you could just enable `unsafe = true` for the Goldmark parser and use a 'normal' HTML comment. As [jmooring](https://discourse.gohugo.io/u/jmooring) likes to say (paraphrased):
>It's not unsafe if you're the one writing it
