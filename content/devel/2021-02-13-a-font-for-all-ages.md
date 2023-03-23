---
slug: a-font-for-all-ages
aliases:
- /2021/02/03/a-font-for-all-ages/
- /post/a-font-for-all-ages/
- /a-font-for-all-ages/
- /docs/web-design/accessibility/a-font-for-all-ages/
- /develop-design/web-design-web-devel/a-font-for-all-ages/
- /docs/devel/a-font-for-all-ages/
- /blog/a-font-for-all-ages/
author: Daniel F. Dickinson
date: '2021-02-13T07:39:44+00:00'
publishDate: '2021-02-03T21:38:50+00:00'
weight: 9000
tags:
- accessibility
- archived
- web-design
title: "A font for all ages"
description: "Especially if you are older, have dirty or inadequate glasses, are just tired, or are using a small screen, you may find websites use an excessively small font."
summary: "Especially if you are older, have dirty or inadequate glasses, are just tired, or are using a small screen, you may find websites use an excessively small font."
---

**ARCHIVED**: This page is archived and may contain information that is out-of-date or no longer accurate.

Especially if you are older, have dirty or inadequate glasses, are just tired, or are using a small screen, you may have noticed that many sites use an excessively small font and that, worse, if you zoom the page, that the formatting of the site 'goes all to pieces'.

Responsive design can help with the latter. One way to aid in responsive design it so make the size of the font displayed proportional to the size of the display.

This is more complicated than it sounds. Generally technology today does a poor job of reporting to CSS or Javascript (which are the web technologies one primarily uses for adjusting styling and having dynamic pages), the actual size of the pixels (dots) that make up the display and the size of the display.

This is especially true of older browsers and devices. As a result one ends up using various 'proxy' measures to attempt to compensate.

The follow Javascript snippet is an example of way to have the font size smoothly adjust to the (via proxy measure) size of the display.

```javascript
// Function to calculate the root font size for html element so that
// all other proportionally defined fonts will be scaled accordingly.
// The idea is to have a smoothly scaling font size as number of pixels gets
// larger.

// This is on the assumption higher resolutions mean more dpi; sadly there is
// no good way to find dpi in javascript and/or with CSS in present browser
// implementations; many solutions have been proposed, but none are consistently
// successful across platforms (and Windows 10 is particularly bad at reporting
// a useful DPI) as of 2017-04-18 23:59:00 -0400

// fontZoom is a constant multiplier (e.g. 1.6 = 160%) for zoom
function calculateFontSize(fontZoom) {
    // Some magic numbers that worked for me.
    // It is basically intuitive approach involving trial and error.
    // The basic idea was to shift and apply constants multipliers
    // to a natural logarithmic scale to get the scaling to 'play nicely'.
    // (Meaning that at small pixel counts font size changes are fast relative
    // to pixel count but de-accelerate as pixel counts go up (but still end up
    // being larger increments on larger displays due to the larger initial value).
    var maxWidth = 999999;
    var minWidth = 1;
    var fontRatio = 1;
    var fontLogScale = 8;
    var fontLogOffset = 105536;
    var fontScale = 109;
    var fontScaleOffset = -11.448;

    // This is the desired font range in css pixels (which are sadly not actually
    // device-independent even though they were supposed to be
    // Note that this only affects cutoff, to get the range to work as desired, you
    // will need to play with the magic numbers.
    var minFont = 16;
    var maxFont = 32;

    minFont = minFont * fontZoom;
    maxFont = maxFont * fontZoom;

    var baseWidth = document.documentElement.offsetWidth;
    var setWidth = baseWidth > maxWidth ? maxWidth : baseWidth < minWidth ? minWidth : baseWidth;
    var fontBase = ((Math.log(fontLogOffset + fontLogScale * (setWidth / fontRatio))) + fontScaleOffset) * fontScale * fontZoom;
    var fontSize = (fontBase > maxFont ? maxFont : fontBase < minFont ? minFont : fontBase) + "px";
    return fontSize;
}

// Function to set the root font size inline (on the html element), thus causing
// all other proportionally defined fonts to be scaled accordingly.
// The idea is to have a smoothly scaling font size as number of pixels gets
// larger.

// This concept was borrowed from Flow.js.
// <https://github.com/simplefocus/FlowType.JS/blob/master/flowtype.js>
// but implemented using completely different code.
// In that case the goal was actually to maintain 45-75 words on a page based
// the theory this is typographically optimal, here we just want smooth scaling on
// within the range of our choice.

// fontZoom is a constant multiplier (e.g. 1.6 = 160%) for zoom
function setFontSizeOnResize() {
    var fontZoom = document.documentElement["cshore-font-zoom"];

    if (!fontZoom || fontZoom < 0) {
        var currentStyle = document.documentElement["cshore-current-style"];
        switch (currentStyle) {
            case "Large Print":
            case "Large Contrast":
            fontZoom = 1.6;
            break;
            default:
            fontZoom = 1;
            break;
        }
    }
    document.documentElement.style["font-size"] = calculateFontSize(fontZoom);
}

function doOnResize() {
    setFontSizeOnResize();
    return true;
}

window.addEventListener("resize", doOnResize);

// Also include doOnResize on your onLoad event else the font scaling won't be applied until window is resized
```

The code is pretty well commented, however I actually stopped using the smooth adjust method, because it can cause 'flickering' during browser resize which can be an accessibility issue for those prone to seizures.

Nowadays, if I am designing a theme, I use CSS and 'breakpoints' which gives a less smooth transition, but is still proportional to the size of the display, which, ultimately, is what matters.

An example is:

```css
@media not speech {
    html {
        font-size: 16px;
    }
}

@media screen and (min-width: 28em) {
    html {
        font-size: 17px;
    }
}

@media screen and (min-width: 36em) {
    html {
        font-size: 18px;
    }
}

@media screen and (min-width: 48em) {
    html {
        font-size: 19px;
    }
}

@media screen and (min-width: 56em) {
    html {
        font-size: 20px;
    }
}

@media screen and (min-width: 64em) {
    html {
        font-size: 21px;
    }
}
```
