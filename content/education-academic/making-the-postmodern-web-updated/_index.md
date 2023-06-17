+++
title = "Making the postmodern web (updated)"
slug = "making-the-postmodern-web-updated"
author = "Daniel F. Dickinson"
date = "2023-02-11T19:30:22Z"
publishDate = "2023-02-11T19:30:22Z"
aliases = [
	"/docs/education-academic/making-the-postmodern-web/",
	"/education-academic/making-the-postmodern-web/",
	"/docs/education-academic/making-the-postmodern-web-updated/",
	"/education-academic/making-the-postmodern-web-updated/making-the-postmodern-web-updated/"
]
card = true
frontCard = true
tags = [
	"web-design"
]
description = "Observations on what you need to build a website that will be found"
summary = """\
Observations on what you need to build a website that will be found: a presentation for the [Midland MakerPlace](https://midlandlibrary.com/the-mpl-makerplace/).\
"""
showChildPages = false
+++

{{< details-toc >}}

## Preface

Observations on what you need to build a website that will be found: a presentation for the [Midland MakerPlace](https://midlandlibrary.com/the-mpl-makerplace/).

### Alternative formats

* [Presentation as a LibreOffice Impress Document (compatible with Microsoft
PowerPoint)](Making-the-postmodern-web.odp)
* [Presentation as a PDF Document](Making-the-postmodern-web.pdf)

### Additional resources

* [Links to more information about creating  and managing
websites](resources)

## About {#about}

### Presenter: Daniel F. Dickinson

* Currently works on his two websites built from scratch
* A small number of other web projects in the past
* More of a software/firmware developer, DevOps specialist, constant
thinker, tinkerer, and would-be writer (non-fiction)

### MPL MakerPlace

* 'This is the place' to explore technology in Midland
* 3D Printing, laser cutting, video and audio creation, old school
physical making, and the digital world (like today's topic).

## Technology / Organization {#technology-organization}

### Technology

* HTML, CSS, JavaScript
* Images/videos
* Accessibility
* Security

### Who is doing the work

* Team or individual
* Technical skill and/or time
* Budget

### SEO (Search Engine Optimization)

* Metadata / Microformats
* Structured data
* Page load speed
* Security
* Observatory / Lighthouse
* Time & content
* Cheating tends to backfire

### Law, art, and social {#law-art-and-social}

#### Legal (topics to consider)

* Accessibility
* Privacy
* Intellectual property
* Expression vs defamation, libel, etc
* What is your 'reach' (international law)
* Attempts to get you shut down, if controversial

#### Audience

* For yourself, audience, or customer?

#### Aesthetics

* Graphics design

#### Social

* Values
* Taste
* Expectations

## Technology to know

### The web is polyglot {#the-web-is-polyglot}

* While the main part of most websites is based on the core language
of the web (HTML), websites are built using multiple computer
languages and technologies.
* This presentation will briefly touch on three of these
languages[^1] (HTML, CSS, JavaScript) and related microformats
(Open Graph, Schema.org, microformats.org).
* Resources for learning more will be provided.
* Remember to start small and simple, and/or tweaking existing.
* Another important aspect of building for the web is 'search engine
optimization' (aka SEO) (which is about how to be found).

## HTML example {#html-example}

* [View it live](https://mice.demo.wildtechgarden.ca/only-mice.html)
* *Italicized teal text is optional.*
* Optional text helps the browser properly interpret the 'encoding'
and language / locale of the content.
* Only `<body>` text appears in the browser pane[^2]
* `<head><title>` is the tab title

```html
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>There's no one here but us mice.</title>
	</head>
	<body>
		<h1>There's no one here but us mice…</h1>
	</body>
</html>
```

## Semantic HTML {#semantic-html}

* HTML 5 introduced the notion of 'semantic' markup which is intended
to make it easier for machines (including screen readers) to
understand' your site
* This includes putting the main part of the site inside a `<main>`
element, and within that, any article part inside an `<article>`
element, additional information in an `<aside>`, and other sections
in `<section>` elements.
* See
[definition](https://developer.mozilla.org/en-US/docs/Glossary/semantics),
[HTML overview](https://developer.mozilla.org/en-US/docs/Web/HTML),
and [relation to
accessibility](https://developer.mozilla.org/en-US/docs/Learn/Accessibility/HTML).

## CSS example {#css-example}

* Usually an HTML page uses an element to pull in the CSS.
* Can also include as a `<style>` element directly in the HTML
* [The mice page with
CSS](https://mice.demo.wildtechgarden.ca/css-mice.html)
* Take a look at the page source to see how it's done.
* [CSS overview](https://developer.mozilla.org/en-US/docs/Web/CSS)

```css
h1 {
	border-bottom: 5px ridge;
	border-top: 5px ridge;
	margin-top: 3rem;
	padding: 2rem;
}
```

## JavaScript example {#javascript-example}

* Usually an HTML page uses an element to pull in the CSS.
* Can also include as a `<script>` element directly in the HTML
* [Mice page with JavaScript](https://mice.demo.wildtechgarden.ca/)
* Use the source, Luke (unknown OpenSource advocate)
* [JavaScript
overview](https://developer.mozilla.org/en-US/docs/Web/javascript)
* Limit JS what is required

```javascript
function noonehere() {
	var h1element = document.getElementById("noonehere")
	h1element.innerHTML = "There's no one here."
}

<h1 id="noonehere" onclick="noonehere()">
```

## Accessibility aka a11y {#accessibility-aka-a11y}

* Vision: contrast, colour-impairment, font size and spacing
* Vision with screen readers / braille 'display'
* Can your reader understand you with less than a PhD?
* Images: 'alt' text and universal design
* Navigation: [Not breaking the back
button](https://www.danielfdickinson.ca/blog/accessible-design-no-blank/)
and more (especially for less tech savvy viewers)
* Videos: subtitles / DV (descriptive video)
* PDF: use a text-based not image-based PDF
* Test it and include testing from those with barriers

## Security {#security}

* Always use HTTPS; if you provider doesn't offer at least a free
"Let's Encrypt" certificate, move your hosting
* DNSSEC: This is harder, but
[OVHcloud](https://www.ovhcloud.com/en-ca/) supports it well.
* CSP (Content Security Policy): It is important to avoid XSS (Cross
site scripting vulnerabilities), "clickjacking", and other
nastiness, but requires your hosting supporting it.
* If you're using a CMS: strong passwords and Multi-factor
Authentication are a must (seriously).
* **Keep your hosting up to date!**

## Who is doing what work

### Team vs. individual {#team-vs.-individual}

* Usually this means a smaller number of individuals handle the
technology, while the 'content' is written / designed by others
* If the writers / designers need to be able to add content directly,
then you need a CMS (Content Management System).
* If the content goes through the technical person/team then you may
not need a web-facing CMS, as the technical person/team would be
responsible for getting the content published
* Of course if your writers / designers have access to publish, then
if they get phished or compromised, so can an attacker.

### Available technical skills / time {#available-technical-skills-time}

* If the team is small and main purpose is not building for the web,
then designing and maintaining your own theme is probably going to
take too much time.
* If contracting out theme design, avoid a 'one-off' relationship as
there **will** be times you need updates.
* If you are using an third party theme, and don't have a lot of
technical expertise, then consider a *managed* web solution (e.g.
where someone else takes care of the updates etc) and just
write/design.
* If you have technical skills then a Static Site Generator (SSG) is ideal.
* If you also have time then your own theme can be worthwhile.

## More control takes more coding {#more-control-takes-more-coding}

* There are many no-code / low-code website building options out
here---see [CIRA\'s CMS (Website builder) speed dating blog
post](https://www.cira.ca/blog/ca-domains/cms-speed-dating-which-platform-should-you-use)
for examples.
* Ultimately these let you build a site quickly, but in most cases you
are limited to the 'building blocks' the provider gives you.
* In the cases where a provider allows you custom 'building blocks',
technical skills in HTML, CSS, JavaScript will be important.
* Sites built by a website builder tend to have issues with page load
speeds, which can negatively affect your search rankings.

## Static site generators (SSG) {#static-site-generators-ssg}

[Benefits of static generators](https://gohugo.io/about/benefits/) from
the [Hugo website](https://gohugo.io/)

[There are many choices; see the top starred ones on
GitHub.](https://jamstack.org/generators/)

In addition to avoiding a database dependency:

* Speed
* Security
* Can review / validate files/sites before you publish

Can use JavaScript and/or non-static servers for dynamic elements like
forms, payments/stores.

* [Jamstack](https://jamstack.org/) is a popular method of doing this.

## CMS based on SSG {#cms-based-on-ssg}

* [Cloud Cannon](https://cloudcannon.com/)
* [Decap CMS](https://decapcms.org/)
* [Tina Cloud](https://tina.io/)
* [Vercel](https://vertcel.com/)
* Quite useful to reduce the required technical skills required to use
a static site generator
* Like a managed dynamic CMS, these generally cost more than managing
yourself, but saves you time and effort.

## SEO (Search Engine Optimization){#seo}

### Page load speeds {#page-load-speeds}

* While not the single most important factor for your search engine
ranking, it is a significant factor.
* Slow loading **is** likely the first thing your visitor will
complain about on an otherwise interesting / well designed site.
* By complain, I mean to themselves; chances of getting feedback other
than lost eyeballs due to page load speeds is unlikely.
* Fortunately there are many techniques for improving load speeds,
especially for the part 'above the fold' (i.e. what first appears).

### Metadata / microformats / structured data {#metadata-microformats-structured-data}

* This is 'stuff' that is not displayed on the page, but is designed
for search engines, and other automated processing, to 'understand'
what is on your site.
* It also includes things like 'Twitter cards' and 'Open Graph
Protocol' images and text. These are used by other sites (like
Twitter) to create the graphic and text that users on those sites
will see when someone includes a link to your site.
* There is also a type of 'microformat' that is embedded in the main
web page, and is designed to help automated processing.

### Lighthouse / web.dev {#lighthouse-web.dev}

* Testing frameworks like Google uses this as part of their 'scoring'
of websites (especially the technical aspects).
* Four topics: Performance, Accessibility, Best Practices, and SEO
* Lighthouse can be used locally from the Chrome or Edge web developer
tools (F12).
* web.dev runs against live sites [such as this report on my tech
site](https://pagespeed.web.dev/analysis?url=https://www.wildtechgarden.ca/)
* Also available for use as an API (e.g. for automated testing before
going live).

### Content is King {#content-is-king}

* More than any 'tricks' for SEO, content matters
* Also, time, and the snowball effect of getting noticed (and linked
to by real sites, and people)
* Additionally, the web is huge and the bots need time to find you.
* Search engines are constantly updating the detection of cheating and
penalize those who do
* Questionable SEO companies will often promote your site in ways
which hurt you more than they help. Being linked to can degrade your
rating, depending on the quality of the linking sites.

## Law, art, and social {#law-art-and-social-1}

### Inclusiveness and expression {#inclusiveness-and-expression}

#### Accessibility; the web should be for everyone

* There is a lot of low hanging fruit, if you are willing to put in a
little time

#### Freedom of expression vs bigotry etc

#### Freedom of expression vs defamation, libel, etc

#### Shutdown attempts

If your site becomes well known and 'rocks the boat' you may experience
attempts to shut you down:

* SLAPP lawsuits
* Copyright and intellectual property as a silencer

### Privacy and your 'reach' {#privacy-and-your-reach}

* EU is coming down hard on things like Google Analytics
* FTC is making noises about dealing with privacy issues
* Some US states (like California) have also strengthened regulation
    around privacy
* Depending on who your customer is (for a business), or whether you
    considered to be subject to a foreign country's jurisdiction is
    messy. Especially for privacy laws it is better to play it safe.
* Also consider CASL and other anti-spam legislation if you want to
    market to your visitors (e.g. newsletters, etc)

### Intellectual property {#intellectual-property}

* Many countries have agreements such that copyright and trademarks in
    one country apply to many other countries as well (with the notable
    exception of countries like China).
* It's generally civil legislation, which means that if someone is
    violating your copyright you have to find out about them, and take
    legal action yourself.
* However, search engines and web hosting companies usually have a
    'notice and take-down' policy (if a site is alleged to be in
    violation, the site owner is given a chance to respond, depending on
    response the site may be removed from listing or taken down).

#### Audience, aesthetics, taste, etc {#audience-aesthetics-taste-etc}

There are two aspects to what you can show on a website, aside from the
legal aspects

How the general public will react (content and/or how 'shocking')

How your 'audience' will react (content and aesthetics)

* But first you have to identify your audience (or if it is mostly for
    yourself, and others can like or not as they feel inclined)
* For example, if your audience prefers minimalism, a flashy and/or
    emoji-filled site is probably not what you want.

Graphics design principles generally hold regardless

## End notes {#end-notes}

[^1]: We use the term language very loosely in this presentation
(for example CSS is not really a language in pure computer science terms).

[^2]: "There's no one here but us mice" is a phrase I seem to remember hearing on "Hogan's Heroes" once, but according to a web search first appeared in a "Looney Tunes" episode as "Nobody here but us mice".
