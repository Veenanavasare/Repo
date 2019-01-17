/*=================================================================
AT&T Partner Exchange Master Stylesheet ---------------------------
===================================================================

stylesheets/
|
|-- modules/                  # Common modules
|   |-- _base                 # Imports all the modules
|   |-- _animation            # CSS animations
|   |-- _colors               # Colors
|   |-- _fonts                # Fonts
|   |-- _mixins               # Imports all mixins & global vars
|   ...
|
|-- modules/                  # Partials
|   |-- _normalize            # http://necolas.github.io/normalize.css
|   |-- _defaults             # Global Defaults
|   |-- _layout               # Imports all layouts
|   |-- _modals               # All the modals
| ...
|   |
|   |-- layout/               # Layout Views for Unauthenticated
|     |-- modals
|     |-- slice_un_hero
|     |-- slice_who_we_are
|     |-- slice_what_we_do
|     |-- slice_products
|     |-- slice_ecosystem
|     |-- slice_testimonial
|     |-- slice_contact
|     ...
|     |-- slice_au_hero       # Layout Views for Authenticated
|
|   |-- _png                  # not built yet, needed for older browsers
|   |-- _firefox
|   |-- _queries
|
|-- vendors/                  # CSS or from other projects
|   ...
|
`-- att_partner_exchange      # Primary Sass file
`-- reset                     # Super reset then adjusted with normalize
*/
/*! normalize.css v3.0.0 | MIT License | git.io/normalize */
/**
 * 1. Set default font family to sans-serif.
 * 2. Prevent iOS text size adjust after orientation change, without disabling
 *    user zoom.
 */
html {
  font-family: sans-serif;
  /* 1 */
  -ms-text-size-adjust: 100%;
  /* 2 */
  -webkit-text-size-adjust: 100%;
  /* 2 */ }

/**
 * Remove default margin.
 */
body {
  margin: 0; }

/* HTML5 display definitions
   ========================================================================== */
/**
 * Correct `block` display not defined in IE 8/9.
 */
article,
aside,
details,
figcaption,
figure,
footer,
header,
hgroup,
main,
nav,
section,
summary {
  display: block; }

/**
 * 1. Correct `inline-block` display not defined in IE 8/9.
 * 2. Normalize vertical alignment of `progress` in Chrome, Firefox, and Opera.
 */
audio,
canvas,
progress,
video {
  display: inline-block;
  /* 1 */
  vertical-align: baseline;
  /* 2 */ }

/**
 * Prevent modern browsers from displaying `audio` without controls.
 * Remove excess height in iOS 5 devices.
 */
audio:not([controls]) {
  display: none;
  height: 0; }

/**
 * Address `[hidden]` styling not present in IE 8/9.
 * Hide the `template` element in IE, Safari, and Firefox < 22.
 */
[hidden],
template {
  display: none; }

/* Links
   ========================================================================== */
/**
 * Remove the gray background color from active links in IE 10.
 */
a {
  background: transparent; }

/**
 * Improve readability when focused and also mouse hovered in all browsers.
 */
a:active,
a:hover {
  outline: 0; }

/* Text-level semantics
   ========================================================================== */
/**
 * Address styling not present in IE 8/9, Safari 5, and Chrome.
 */
abbr[title] {
  border-bottom: 1px dotted; }

/**
 * Address style set to `bolder` in Firefox 4+, Safari 5, and Chrome.
 */
b,
strong {
  font-weight: normal; }

/**
 * Address styling not present in Safari 5 and Chrome.
 */
dfn {
  font-style: italic; }

/**
 * Address variable `h1` font-size and margin within `section` and `article`
 * contexts in Firefox 4+, Safari 5, and Chrome.
 */
h1 {
  font-size: 2em;
  margin: 0.67em 0; }

/**
 * Address styling not present in IE 8/9.
 */
mark {
  background: #ff0;
  color: #000; }

/**
 * Address inconsistent and variable font size in all browsers.
 */
small {
  font-size: 80%; }

/**
 * Prevent `sub` and `sup` affecting `line-height` in all browsers.
 */
sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline; }

sup {
  top: -0.5em; }

sub {
  bottom: -0.25em; }

/* Embedded content
   ========================================================================== */
/**
 * Remove border when inside `a` element in IE 8/9.
 */
img {
  border: 0; }

/**
 * Correct overflow displayed oddly in IE 9.
 */
svg:not(:root) {
  overflow: hidden; }

/* Grouping content
   ========================================================================== */
/**
 * Address margin not present in IE 8/9 and Safari 5.
 */
figure {
  margin: 1em 40px; }

/**
 * Address differences between Firefox and other browsers.
 */
hr {
  -moz-box-sizing: content-box;
  box-sizing: content-box;
  height: 0; }

/**
 * Contain overflow in all browsers.
 */
pre {
  overflow: auto; }

/**
 * Address odd `em`-unit font size rendering in all browsers.
 */
code,
kbd,
pre,
samp {
  font-family: monospace, monospace;
  font-size: 1em; }

/* Forms
   ========================================================================== */
/**
 * Known limitation: by default, Chrome and Safari on OS X allow very limited
 * styling of `select`, unless a `border` property is set.
 */
/**
 * 1. Correct color not being inherited.
 *    Known issue: affects color of disabled elements.
 * 2. Correct font properties not being inherited.
 * 3. Address margins set differently in Firefox 4+, Safari 5, and Chrome.
 */
button,
input,
optgroup,
select,
textarea {
  color: inherit;
  /* 1 */
  font: inherit;
  /* 2 */
  margin: 0;
  /* 3 */ }

/**
 * Address `overflow` set to `hidden` in IE 8/9/10.
 */
button {
  overflow: visible; }

/**
 * Address inconsistent `text-transform` inheritance for `button` and `select`.
 * All other form control elements do not inherit `text-transform` values.
 * Correct `button` style inheritance in Firefox, IE 8+, and Opera
 * Correct `select` style inheritance in Firefox.
 */
button,
select {
  text-transform: none; }

/**
 * 1. Avoid the WebKit bug in Android 4.0.* where (2) destroys native `audio`
 *    and `video` controls.
 * 2. Correct inability to style clickable `input` types in iOS.
 * 3. Improve usability and consistency of cursor style between image-type
 *    `input` and others.
 */
button,
html input[type="button"],
input[type="reset"],
input[type="submit"] {
  -webkit-appearance: button;
  /* 2 */
  cursor: pointer;
  /* 3 */ }

/**
 * Re-set default cursor for disabled elements.
 */
button[disabled],
html input[disabled] {
  cursor: default; }

/**
 * Remove inner padding and border in Firefox 4+.
 */
button::-moz-focus-inner,
input::-moz-focus-inner {
  border: 0;
  padding: 0; }

/**
 * Address Firefox 4+ setting `line-height` on `input` using `!important` in
 * the UA stylesheet.
 */
input {
  line-height: normal; }

/**
 * It's recommended that you don't attempt to style these elements.
 * Firefox's implementation doesn't respect box-sizing, padding, or width.
 *
 * 1. Address box sizing set to `content-box` in IE 8/9/10.
 * 2. Remove excess padding in IE 8/9/10.
 */
input[type="checkbox"],
input[type="radio"] {
  box-sizing: border-box;
  /* 1 */
  padding: 0;
  /* 2 */ }

/**
 * Fix the cursor style for Chrome's increment/decrement buttons. For certain
 * `font-size` values of the `input`, it causes the cursor style of the
 * decrement button to change from `default` to `text`.
 */
input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
  height: auto; }

/**
 * 1. Address `appearance` set to `searchfield` in Safari 5 and Chrome.
 * 2. Address `box-sizing` set to `border-box` in Safari 5 and Chrome
 *    (include `-moz` to future-proof).
 */
input[type="search"] {
  -webkit-appearance: textfield;
  /* 1 */
  -moz-box-sizing: content-box;
  -webkit-box-sizing: content-box;
  /* 2 */
  box-sizing: content-box; }

/**
 * Remove inner padding and search cancel button in Safari and Chrome on OS X.
 * Safari (but not Chrome) clips the cancel button when the search input has
 * padding (and `textfield` appearance).
 */
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-decoration {
  -webkit-appearance: none; }

/**
 * Define consistent border, margin, and padding.
 */
fieldset {
  border: 1px solid #c0c0c0;
  margin: 0 2px;
  padding: 0.35em 0.625em 0.75em; }

/**
 * 1. Correct `color` not being inherited in IE 8/9.
 * 2. Remove padding so people aren't caught out if they zero out fieldsets.
 */
legend {
  border: 0;
  /* 1 */
  padding: 0;
  /* 2 */ }

/**
 * Remove default vertical scrollbar in IE 8/9.
 */
textarea {
  overflow: auto; }

/**
 * Don't inherit the `font-weight` (applied by a rule above).
 * NOTE: the default cannot safely be changed in Chrome and Safari on OS X.
 */
optgroup {
  font-weight: bold; }

/* Tables
   ========================================================================== */
/**
 * Remove most spacing between table cells.
 */
table {
  border-collapse: collapse;
  border-spacing: 0; }

td,
th {
  padding: 0; }

/* http://meyerweb.com/eric/tools/css/reset/ 
   v2.0 | 20110126
   License: none (public domain)
*/
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, center,
dl, dt, dd, ol, ul, li,i,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  /*font: inherit; */
  vertical-align: baseline; }
  

/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block; }

body {
  line-height: 1; }

ol, ul {
  list-style: none; }

blockquote, q {
  quotes: none; }

blockquote:before, blockquote:after,
q:before, q:after {
  content: '';
  content: none; }

table {
  border-collapse: collapse;
  border-spacing: 0; }

/* PIXELS to EM */
/* TRIANGLE */
/* FROM BOURBON */
/* FLEXBOX */
/* Generated by Font Squirrel (http://www.fontsquirrel.com) on August 22, 2014 */
@font-face {
  font-family: 'omnes_light';
  src: url("PortalDesignFonts/omnes_att_ii_light-webfont.eot");
  src: url("PortalDesignFonts/omnes_att_ii_light-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_att_ii_light-webfont.woff2") format("woff2"), url("PortalDesignFonts/omnes_att_ii_light-webfont.woff") format("woff"), url("PortalDesignFonts/omnes_att_ii_light-webfont.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii_light-webfont.svg#omnes_att_iilight") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'omnes_att_iilight_italic';
  src: url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.eot");
  src: url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.svg#omnes_att_iilight_italic") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'omnes_att_iimedium';
  src: url("PortalDesignFonts/omnes_att_ii_medium-webfont.eot");
  src: url("PortalDesignFonts/omnes_att_ii_medium-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_att_ii_medium-webfont.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii_medium-webfont.svg#omnes_att_iimedium") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'omnesatt_iiregular';
  src: url("PortalDesignFonts/omnes_att_ii-regular-webfont.eot");
  src: url("PortalDesignFonts/omnes_att_ii-regular-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_att_ii-regular-webfont.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii-regular-webfont.svg#omnesatt_iiregular") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'omnes_att_iimedium_italic';
  src: url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.eot");
  src: url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.woff2") format("woff2"), url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.woff") format("woff"), url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.svg#omnes_att_iimedium_italic") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'clearviewattregular';
  src: url("PortalDesignFonts/clvatt-book-webfont.eot");
  src: url("PortalDesignFonts/clvatt-book-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/clvatt-book-webfont.ttf") format("truetype"), url("PortalDesignFonts/clvatt-book-webfont.svg#clearviewattregular") format("svg");
  font-weight: normal;
  font-style: normal; }
@font-face {
  font-family: 'clearviewattlight';
  src: url("PortalDesignFonts/clvatt-light-webfont.eot");
  src: url("PortalDesignFonts/clvatt-light-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/clvatt-light-webfont.woff2") format("woff2"), url("PortalDesignFonts/clvatt-light-webfont.woff") format("woff"), url("PortalDesignFonts/clvatt-light-webfont.ttf") format("truetype"), url("PortalDesignFonts/clvatt-light-webfont.svg#clearviewattlight") format("svg");
  font-weight: normal;
  font-style: normal; }
@-webkit-keyframes pulseBorder {
  from {
    border: solid 2px #3bc1f4; }
  to {
    border: solid 2px #fff; } }
/* START OF ATT FOUNDRY STYLES | DEFAULTS
====================================================
==================================================== */
.navbar-default .navbar-collapse, .navbar-default .navbar-form {
  background: #fff; }

.modal-content {
  -webkit-box-shadow: none;
  border: 0;
  background: transparent !important; }

/* CUSTOMIZE THE NAVBAR
-------------------------------------------------- */
/* Special class on .container surrounding .navbar, used for positioning it into place. */
/* Flip around the padding for proper display in narrow viewports */
/* CUSTOMIZE THE CAROUSEL
-------------------------------------------------- */
/* Carousel base class */
/* Since positioning the image, we need to help out the caption */
/* Declare heights because of positioning of img element */
/* MARKETING CONTENT
-------------------------------------------------- */
/* Center align the text within the three columns below the carousel */
/* Featurettes
------------------------- */
/* Space out the Bootstrap <hr> more */
/* Thin out the marketing headings */
/* RESPONSIVE CSS
-------------------------------------------------- */
html, body {
  width: 100%;
  height: 100%; }

body {
  font-family: omnesatt_iiregular;
  font-size: 1em;
  overflow-x: hidden;
  background: #f7f7f7; }

strong {
  font-family: 'omnes_att_iimedium';}

.unauthenticated_body {
  background: #fff; }

.enter_pass {
  display: none;
  width: 600px;
  margin: 30px auto 0;
  background: #FFF;
  padding: 10px 50px 50px;
  /* form starting stylings ------------------------------- */
  /* LABEL ======================================= */
  /* active state */
  /* BOTTOM BARS ================================= */
  /* active state */
  /* HIGHLIGHTER ================================== */
  /* active state */
  /* ANIMATIONS ================ */ }
  .enter_pass img {
    margin-bottom: 40px; }
  .enter_pass .group {
    position: relative;
    margin-bottom: 45px; }
  .enter_pass input {
    font-size: 18px;
    padding: 10px 10px 10px 5px;
    display: block;
    width: 100%;
    border: none;
    border-bottom: 1px solid #757575; }
  .enter_pass input:focus {
    outline: none; }
  .enter_pass label {
    color: #999;
    font-size: 18px;
    font-weight: normal;
    position: absolute;
    pointer-events: none;
    left: 5px;
    top: 10px;
    transition: 0.2s ease all;
    -moz-transition: 0.2s ease all;
    -webkit-transition: 0.2s ease all; }
  .enter_pass input:focus ~ label, .enter_pass input:valid ~ label {
    top: -20px;
    font-size: 14px;
    color: #5264AE; }
  .enter_pass .bar {
    position: relative;
    display: block;
    width: 100%; }
  .enter_pass .bar:before, .enter_pass .bar:after {
    content: '';
    height: 2px;
    width: 0;
    bottom: 1px;
    position: absolute;
    background: #5264AE;
    transition: 0.2s ease all;
    -moz-transition: 0.2s ease all;
    -webkit-transition: 0.2s ease all; }
  .enter_pass .bar:before {
    left: 50%; }
  .enter_pass .bar:after {
    right: 50%; }
  .enter_pass input:focus ~ .bar:before, .enter_pass input:focus ~ .bar:after {
    width: 50%; }
  .enter_pass .highlight {
    position: absolute;
    height: 60%;
    width: 100%;
    top: 25%;
    left: 0;
    pointer-events: none;
    opacity: 0.5; }
  .enter_pass input:focus ~ .highlight {
    -webkit-animation: inputHighlighter 0.3s ease;
    -moz-animation: inputHighlighter 0.3s ease;
    animation: inputHighlighter 0.3s ease; }
@-webkit-keyframes inputHighlighter {
  from {
    background: #5264AE; }
  to {
    width: 0;
    background: transparent; } }
@-moz-keyframes inputHighlighter {
  from {
    background: #5264AE; }
  to {
    width: 0;
    background: transparent; } }
@keyframes inputHighlighter {
  from {
    background: #5264AE; }
  to {
    width: 0;
    background: transparent; } }
.password_check {
  width: 100%; }

#must_pass_submit {
  padding: 20px 40px;
  width: 100%;
  border: none;
  color: white;
  background: #056fab;
  -webkit-border-radius: 6px;
  border-radius: 6px;
  transition: 0.5s ease all;
  -moz-transition: 0.5s ease all;
  -webkit-transition: 0.5s ease all; }
  #must_pass_submit:hover {
    background: #3bc1f4; }

.slice {
  margin: 90px 0; }

sup, sub {
  font-size: 75%;
  line-height: 0;
  vertical-align: baseline; }

sup {
  top: -0.5em;
  left: 0.15em; }

sub {
  bottom: -0.25em; }

input[type=checkbox].css-checkbox {
  position: absolute;
  overflow: hidden;
  top: -1000px;
  margin: -1px;
  padding: 0;
  padding-left: 27px;
  z-index: -1000;
  clip: rect(0 0 0 0);
  height: 1px;
  width: 1px;
  border: 0; }

input[type=checkbox].css-checkbox + label.css-label,
input[type=checkbox].css-checkbox + label.css-label.clr {
  padding-left: 27px;
  height: 17px;
  display: inline-block;
  line-height: 17px;
  background-repeat: no-repeat;
  background-position: 0 0;
  font-size: 17px;
  vertical-align: middle;
  cursor: pointer; }

input[type=checkbox].css-checkbox:checked + label.css-label,
input[type=checkbox].css-checkbox + label.css-label.chk {
  background-position: 0 -17px; }

label.css-label {
  background-image: url(PortalUnauthImg/csscheckbox.png);
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none; }

/* Circular Content Carousel Style
====================================================
==================================================== */
.ca-container {
  position: relative;
  margin: 0 auto 20px auto;
  width: 990px;
  height: 420px; }

.ca-wrapper {
  width: 100%;
  height: 100%;
  position: relative; }

.ca-item {
  position: relative;
  float: left;
  width: 330px;
  height: 100%;
  text-align: center; }
  .ca-item h3 {
    margin: 20px 0;
    font-family: omnes_att_iilight_italic;
    font-size: 1.75em;
    color: #056fab;
    text-align: center;
    text-shadow: 0px 1px 1px #e4ebe9; }
  .ca-item h4 {
    font-size: 1.125em;
    color: #056fab; }
  .ca-item p {
    position: relative;
    margin: 10px;
    font-size: 1em;
    line-height: 1.25em;
    color: #666666;
    text-align: center; }

.ca-more {
  position: absolute;
  bottom: 0px;
  right: 0px;
  padding: 10px 20px;
  font-family: clearviewattregular;
  font-size: 1em;
  text-align: center;
  color: #fff;
  background: #056fab; }
  .ca-more:hover {
    color: #fff;
    text-decoration: none; }

.ca-close {
  position: absolute;
  top: 10px;
  right: 10px;
  width: 27px;
  height: 27px; }

.ca-close:hover {
  opacity: 1.0; }

.ca-item-main {
  position: absolute;
  padding: 20px;
  top: 5px;
  left: 5px;
  right: 5px;
  bottom: 5px;
  background: #fff;
  overflow: hidden; }

.ca-icon {
  position: relative;
  margin: 0 auto 15px;
  width: 103px;
  height: 103px; }

.ca-content-wrapper {
  position: absolute;
  top: 5px;
  width: 0px;
  /* expands to width of the wrapper minus 1 element */
  height: 410px;
  text-align: left;
  background: #fff;
  z-index: 10000;
  overflow: hidden; }

.ca-content {
  width: 660px;
  overflow: hidden; }

.ca-content-text {
  line-height: 20px; }
  .ca-content-text p {
    padding-bottom: 5px;
    text-align: left !important; }

.ca-content {
  padding: 40px; }
  .ca-content h6 {
    margin: 25px 20px 0 0;
    font-size: 1.75em;
    padding-bottom: 5px;
    font-family: omnes_att_iilight_italic;
    text-align: left !important;
    color: #056fab;
    border-bottom: none; }
  .ca-content ul {
    margin: 20px 8px;
    height: 30px; }
  .ca-content li {
    float: left;
    margin: 0 0 0 8px;
    list-style: disc;
    margin-bottom: 15px;
    }

.ca-nav span {
  position: absolute;
  top: 50%;
  margin-top: -19px;
  left: -40px;
  width: 25px;
  height: 38px;
  text-indent: -9000px;
  opacity: 0.7;
  z-index: 100;
  cursor: pointer; }
  .ca-nav span .ca-nav-next {
    background-position: top right;
    left: auto;
    right: -40px; }
  .ca-nav span:hover {
    opacity: 1.0; }

/* LAYOUT
====================================================
==================================================== */
/* SLICE: HERO
====================================================
==================================================== */
#slice_hero {
  margin-bottom: 90px;
  padding: 160px 0 0 0;
  width: 100%;
  height: 600px;
  background: url(PortalUnauthImg/hero_girl.jpg) 0 0 no-repeat;
  background-size: cover; }
  #slice_hero .jumbotron {
    background: transparent;
    overflow: visible; }
  #slice_hero h1 {
    color: #056fab;
    margin-bottom: 10px;
    font-family: omnes_att_iilight_italic;
    font-size: 2.75em; }
  #slice_hero h2 {
    color: #666;
    font-size: 1.25em; }

.navbar-nav > li > a {
  padding: 5px 10px; }

.hero_badge,
.hero_badge_bg {
  position: relative;
  top: 60px;
  left: 0px;
  padding: 20px 40px;
  max-width: 750px;
  width: 750px;
  height: 120px;
  -webkit-border-radius: 6px;
  border-radius: 6px; }
  .hero_badge:after,
  .hero_badge_bg:after {
    content: "";
    display: table;
    clear: both; }

.hero_badge {
  z-index: 3; }

.hero_badge_bg {
  top: -60px;
  background: #fff;
  opacity: .75;
  z-index: 2; }

.hero_down {
  float: right;
  position: relative !important;
  top: 70px;
  width: 44px;
  height: 44px;
  background-position: -120px -240px;
  cursor: pointer; }

.apply_now_hero {
  position: relative;
  top: -20px;
  padding: 15px 45px;
  color: #fff;
  background: #056fab;
  opacity: 1;
  -webkit-transition: background 0.3s ease-in-out;
  -ms-transition: background 0.3s ease-in-out;
  -o-transition: background 0.3s ease-in-out;
  transition: background 0.3s ease-in-out;
  -webkit-border-radius: 6px;
  border-radius: 6px; }
  .apply_now_hero:hover {
    color: #fff;
    text-decoration: none;
    background: #1ea9f8; }

/* SLICE: WHO WE ARE
====================================================
==================================================== */
#slice_who_we_are {
  background: #fff; }
  #slice_who_we_are h3 {
    margin-bottom: 20px;
    font-family: omnes_att_iimedium;
    font-size: 2.25em;
    color: #056fab; }
  #slice_who_we_are p {
    font-family: omnesatt_iiregular;
    font-size: 1.125em;
    line-height: 1.375em; }

.copy_block {
  display: inline-block;
  position: relative;
  max-width: 520px;
  /*text-align: center;*/ }

.copy_block_1 {
  top: 55px; }

.copy_block_2 {
  top: 70px; }

.copy_block_3 {
  top: 70px; }

.ipad_view {
  display: none; }

/* SLICE: WHAT WE DO
====================================================
==================================================== */
#slice_what_we_do {
  width: 100%;
  background: url(PortalUnauthImg/cool_office.jpg) 0 0 no-repeat;
  background-size: cover; }
  #slice_what_we_do .jumbotron {
    margin-bottom: 0;
    background: transparent;
    overflow: visible; }

.what_we_do_copy,
.what_we_do_copy_bg {
  position: relative;
  right: -45%;
  /*padding: 20px 40px;*/
  max-width: 750px;
  width: 700px;
  height: 200px; }
  .what_we_do_copy:after,
  .what_we_do_copy_bg:after {
    content: "";
    display: table;
    clear: both; }

.what_we_do_copy_bg {
  -webkit-border-radius: 6px;
  border-radius: 6px; }

.what_we_do_copy {
  top: 110px;
  padding: 0 40px;
  text-align: center;
  color: #fff;
  z-index: 3; }
  .what_we_do_copy h3 {
    margin: 30px 0 40px;
    font-family: omnes_att_iimedium;
    font-size: 2.25em; }
  .what_we_do_copy em {
    color: #ef6f00; }
  .what_we_do_copy p {
    font-family: omnesatt_iiregular;
    font-size: 1.125em; }

.what_we_do_copy_bg {
  top: -50px;
  background: #000;
  opacity: .8;
  z-index: 2; }

/*  Slice Products
====================================================
==================================================== */
#slice_products {
  padding: 100px 0 0 0;
  width: 100%; }
  #slice_products h1, #slice_products h2 {
    text-align: center; }
  #slice_products h1 {
    margin: 30px 0 40px;
    font-family: omnes_att_iimedium;
    font-size: 2.625em;
    color: #056fab; }
  #slice_products h2 {
    font-family: omnesatt_iiregular;
    font-size: 1.125em; }
  #slice_products .jumbotron {
    margin-bottom: 0;
    padding-bottom: 20px; }

.subhead {
  position: relative;
  top: -10px; }

.products_header {
  margin-bottom: 50px; }

#products_mobile_size {
  display: none; }

.ico_globe,
.ico_wifi,
.ico_cloud {
  width: 103px;
  height: 103px; }

.ico_globe {
  background-position: -1px -121px; }

.ico_wifi {
  background-position: -121px -121px; }

.ico_cloud {
  background-position: -241px -121px; }

.ico_x {
  width: 24px;
  height: 24px;
  background-position: -360px -120px; }

.more_arr {
  position: relative;
  top: 2px;
  left: 5px;
  float: right;
  margin: 5px 0 0 10px;
  width: 10px;
  height: 10px;
  background-position: -360px -160px; }

.view_all_products,
.blue_tri {
  position: relative;
  z-index: 3; }

.view_all_products {
  margin: 0 auto;
  padding: 20px;
  width: 980px;
  color: #666;
  text-align: center;
  background: #fff;
  border-bottom: 1px solid #eaeaea; }

.blue_tri {
  top: -1px;
  width: 20px;
  height: 11px;
  background-position: -180px -240px; }

#all_products {
  margin: 40px auto;
  text-align: left; }
  #all_products h2 {
    margin-bottom: 20px;
    font-family: omnes_att_iilight_italic;
    font-size: 1.375em;
    text-align: left;
    color: #056fab; }
  #all_products ul {
    margin-bottom: 40px; }
  #all_products li {
    margin-bottom: 7px;
    color: #666;
    line-height: 1.5em; }
    #all_products li:first-child {
      margin-bottom: 0; }

.all_products_container {
  float: none !important;
  position: relative;
  top: -52px;
  margin: 0 auto;
  padding: 40px 20px;
  width: 980px;
  height: 370px;
  background: #fff; }

.pop_product {
  font-size: 0.875em;
  color: #009add !important;
  cursor: pointer; }
  .pop_product:hover {
    text-decoration: none;
    color: #0e226c; }

.no_product {
  font-size: 0.875em; }

.li_header {
  margin-bottom: 20px;
  height: 50px;
  color: #040b09;
  cursor: auto; }

.cloud_and_hosting {
  position: relative;
  top: -10px; }

.products_globe,
.products_wifi,
.products_cloud {
  float: left;
  margin: 0 15px 10px 0 !important; }

.products_globe {
  width: 39px;
  height: 38px;
  background-position: 0px -240px; }

.products_wifi {
  width: 36px;
  height: 31px;
  background-position: -40px -240px; }

.products_cloud {
  width: 37px;
  height: 25px;
  background-position: -80px -240px; }

.products_api {
  float: left;
  margin: 0 15px 10px 0; }

.api_li {
  margin-top: 30px !important; }

.ico_x {
  cursor: pointer; }

.test_slice {
  color: white; }
  .test_slice .col-sm-3 {
    background: blue; }
  .test_slice .col-sm-9 {
    background: red; }

.product_smll {
  position: relative;
  margin: 20px 0;
  padding: 40px 20px 0 20px;
  background: #fff;
  border: 2px solid #e9e9e9;
  z-index: 3; }
  .product_smll h3 {
    font-family: omnes_att_iilight_italic;
    font-size: 1.75em;
    color: #056fab;
    margin-bottom: 20px;
    text-align: center;
    text-shadow: 0px 1px 1px #e4ebe9; }
  .product_smll h4 {
    font-size: 1.125em;
    color: #056fab; }
  .product_smll p {
    position: relative;
    margin: 10px 0 30px;
    font-family: clearviewattregular;
    font-size: 1em;
    line-height: 1.25em;
    color: #666666;
    text-align: center; }

.more_down {
  position: relative;
  top: 2px;
  margin: 0 auto;
  padding: 10px;
  width: 100px;
  color: #fff;
  background: #3381b7;
  cursor: pointer; }
  .more_down:hover {
    background: #4f9ace; }

.more_arr_down {
  float: right;
  position: relative;
  top: 5px;
  left: -5px;
  width: 10px;
  height: 10px;
  background-position: -390px -160px; }

.product_smll_more {
  display: none;
  position: relative;
  margin-top: -22px;
  margin-bottom: 40px;
  padding: 30px;
  text-align: center !important;
  background: #f7f7f7;
  border: 2px solid #e9e9e9;
  z-index: 2; }
  .product_smll_more h6 {
    font-size: 32px;
    padding-bottom: 5px;
    font-family: omnes_att_iilight_italic;
    color: #056fab; }
  .product_smll_more p {
    margin: 10px 0;
    font-family: clearviewattregular;
    font-size: 1em;
    line-height: 1.25em;
    color: #666666;
    text-align: center !important; }
  .product_smll_more .ico_x {
    margin-top: 20px; }

.overlay {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: #000;
  opacity: .8;
  z-index: 1031;
  cursor: pointer; }

.product_modals_container {
  display: none;
  position: absolute; }
  .product_modals_container section {
    margin: 0 auto;
    min-width: 640px;
    background: blue; }

.m_virtual_private_network,
.m_network_mis,
.m_network_ip_vpn,
.m_network_internet_access,
.m_network_firewall,
.m_network_switched_ethernet_service,
.m_network_private_cloud,
.m_network_colocation_hosting,
.m_network_synaptic_storage,
.m_network_synaptic_compute,
.m_network_ring_central,
.m_network_wireless,
.m_network_business_connect,
.m_network_push_to_talk {
  position: absolute; }

.p_modal {
  padding: 40px;
  width: 100%;
  line-height: 1.25em;
  color: #333;
  background: #fff;
  -webkit-border-radius: 6px;
  border-radius: 6px; }
  .p_modal .ico_x {
    position: absolute;
    top: 20px;
    right: 20px; }
  .p_modal h1 {
    margin: 0 0 10px 0 !important;
    padding-right: 20px;
    font-family: omnes_att_iilight_italic !important;
    font-size: 2.375em;
    text-align: left !important;
    color: #056fab;
    line-height: 1.25em; }
  .p_modal h4 {
    margin-bottom: 15px;
    font-family: omnes_att_iimedium;
    color: #ef6f00; }
  .p_modal p, .p_modal li {
    font-size: 1em !important; }
  .p_modal p {
    margin: 15px 0; }
  .p_modal ul {
    margin-left: 20px; }
  .p_modal li {
    margin: 10px 0 10px 20px;
    list-style: disc; }

.modal-content {
  box-shadow: none; }

/* ECOSYSTEM CONTAINER
====================================================
==================================================== */
.eco_jumbotron {
  margin: 0;
  padding: 0; }

#ecosystem_block {
  position: relative;
  width: 100%;
  height: 680px;
  overflow: hidden;
  background-color: #fff; }

.ecosystem_header {
  position: relative;
  margin: 0 auto;
  padding-top: 65px;
  width: 900px;
  color: #fff;
  z-index: 3; }
  .ecosystem_header h1 {
    margin-bottom: 65px;
    font-family: omnes_att_iimedium;
    font-size: 2.625em;
    color: #056fab;
    text-align: center; }

.eco_subhead {
  margin: -35px auto 40px auto;
  width: 90%;
  font-family: omnesatt_iiregular;
  font-size: 1.125em;
  color: #040b09;
  line-height: 1.5em;
  text-align: center; }

.white_out {
  position: absolute;
  top: 0;
  width: 100%;
  height: 100%;
  background: #fff;
  opacity: .7;
  z-index: 2; }

.videobg {
  position: absolute;
  top: 0;
  width: 100%;
  height: auto;
  margin: 0 auto;
  z-index: 1; }

/* TILES
====================================================
==================================================== */
.eco_tiles {
  position: relative;
  margin: 0 auto;
  width: 900px;
  z-index: 3; }

.top_group {
  position: absolute;
  z-index: 4;
  -moz-user-select: none;
  -khtml-user-select: none;
  -webkit-user-select: none;
  -o-user-select: none; }
  .top_group h2 {
    padding-top: 15px;
    margin: 0 auto;
    width: 90%; }

.top_tile {
  position: absolute;
  width: 170px;
  font-family: omnes_att_iimedium;
  text-align: center;
  color: #fff;
  opacity: .2;
  background: #3bc1f4;
  cursor: pointer;
  -webkit-border-radius: 6px;
  border-radius: 6px;
  -webkit-transition: background 0.2s ease-in-out;
  -ms-transition: background 0.2s ease-in-out;
  -o-transition: background 0.2s ease-in-out;
  transition: background 0.2s ease-in-out; }
  .top_tile:hover {
    background: #0b1b55 !important; }

.direct_connect_small {
  display: none; }

.tile_program_members_copy,
.tile_direct_platform_copy,
.tile_software_vendors_copy,
.tile_service_providers_copy,
.tile_app_developers_copy {
  display: none;
  position: relative;
  margin: 20px auto;
  width: 80%;
  height: 120px;
  font-family: omnesatt_iiregular;
  font-size: 1em;
  line-height: 1.25em;
  opacity: 0;
  z-index: 2; }

.tile_program_members_content,
.tile_direct_platform_content,
.tile_software_vendors_content,
.tile_app_developers_content,
.tile_service_providers_content {
  height: 40px;
  opacity: 0; }

.tile_program_members {
  top: 100px;
  left: 400px;
  width: 80px;
  height: 45px;
  opacity: 0; }

.tile_software_vendors {
  top: 60px;
  left: 440px;
  width: 80px;
  height: 45px;
  opacity: 0; }

.tile_app_developers {
  top: -90px;
  left: 490px;
  width: 80px;
  height: 45px;
  opacity: 0; }

.tile_direct_platform {
  top: -140px;
  left: 440px;
  width: 80px;
  height: 45px;
  opacity: 0; }

.tile_service_providers {
  top: -240px;
  left: 430px;
  width: 70px;
  height: 40px;
  opacity: 0; }

.ico_program_members {
  top: 10px;
  width: 59px;
  height: 43px;
  background-position: 0 -280px; }

.ico_direct_platform {
  top: 20px;
  width: 49px;
  height: 49px;
  background-position: 0px -470px; }

.ico_service_providers {
  top: 20px;
  width: 56px;
  height: 37px;
  background-position: 0px -330px; }

.ico_software_vendors {
  top: 20px;
  width: 42px;
  height: 47px;
  background-position: 0px -370px; }

.ico_app_developers {
  top: 15px;
  width: 45px;
  height: 45px;
  background-position: 0px -420px; }

.mid_group {
  position: absolute;
  top: 0px;
  left: 12px;
  z-index: 3; }

.med_tile {
  position: relative;
  width: 60px;
  height: 30px;
  background: #056fab;
  opacity: 0;
  -webkit-border-radius: 3px;
  border-radius: 3px; }

.med_1_weather {
  top: 155px;
  left: 450px; }

.med_2_email {
  top: 155px;
  left: 450px; }

.ico_email {
  top: 14px;
  width: 17px;
  height: 14px;
  background-position: -240px -50px; }

.med_3_stocks {
  top: 75px;
  left: 350px; }

.med_4_dash {
  top: 40px;
  left: 550px; }

.ico_dash {
  top: 15px;
  width: 25px;
  height: 25px;
  background-position: 0px -49px; }

.med_5_home {
  top: -125px;
  left: 550px; }

.med_6_calendar {
  top: -40px;
  left: 450px; }

.ico_calendar {
  top: 18px;
  width: 22px;
  height: 23px;
  background-position: -50px -50px; }

.med_7_eye {
  top: -175px;
  left: 260px;
  width: 52px;
  height: 30px; }

.ico_eye {
  top: 16px;
  width: 16px;
  height: 10px;
  background-position: -280px -50px; }

.med_8_battery {
  top: -125px;
  left: 490px; }

.ico_battery {
  top: 16px;
  width: 27px;
  height: 17px;
  background-position: -90px -50px; }

.ico_weather {
  top: 18px;
  width: 30px;
  height: 20px;
  background-position: -200px -50px; }

.ico_stocks {
  top: 18px;
  width: 17px;
  height: 20px;
  background-position: -170px -50px; }

.ico_home_wifi {
  top: 18px;
  width: 23px;
  height: 17px;
  background-position: -130px -50px; }

/* MODALS
====================================================
==================================================== */
.modals {
  position: relative;
  z-index: 15; }

.mod {
  position: absolute;
  top: 85px;
  left: 0;
  right: 0;
  margin-left: auto;
  margin-right: auto;
  padding: 40px;
  width: 80%;
  height: 250px;
  color: #fff;
  background: #056fab;
  -webkit-border-radius: 4px;
  border-radius: 4px; }
  .mod h2 {
    font-size: 1.5em;
    margin-bottom: 20px; }
  .mod p {
    font-size: 1em; }

.modal_program_members,
.modal_software_vendors,
.modal_service_providers,
.modal_app_developers,
.modal_direct_platform {
  display: none; }

.ico_close_x {
  float: right;
  position: relative;
  top: -15px;
  left: 15px;
  width: 27px;
  height: 27px;
  background-position: 0px -80px;
  cursor: pointer;
  z-index: 1040; }
  .ico_close_x:hover {
    opacity: .5; }

/* TESTIMONIAL STYLES
====================================================
==================================================== */
#slice_testimonial {
  padding-top: 0 !important;
  padding-bottom: 0;
  width: 100%; }
  #slice_testimonial .jumbotron {
    margin-bottom: 0; }

.jumbotron_testimonial {
  padding: 0 0 100px 0;
  background: #EEE; }
  .jumbotron_testimonial h2 {
    margin: 50px 0 80px;
    font-family: omnes_att_iimedium;
    font-size: 2.625em;
    text-align: center;
    color: #056fab; }

.testimonials_container {
  margin: 0 auto; }

.testimonial_bubble {
  float: left;
  padding: 15px;
  max-width: 30%;
  margin: 0 0 30px 40px;
  background: #FFF;
  -moz-box-shadow: 1px 1px 4px rgba(0, 0, 0, 0.2);
  -webkit-box-shadow: 1px 1px 4px rgba(0, 0, 0, 0.2);
  box-shadow: 1px 1px 4px rgba(0, 0, 0, 0.2);
  -webkit-border-radius: 6px;
  border-radius: 6px; }
  .testimonial_bubble:after {
    background-image: url(PortalUnauthImg/bubble_corner.png); }
  .testimonial_bubble h1 {
    margin-bottom: 15px;
    font-family: omnes_att_iimedium_italic;
    font-size: 1.5em;
    color: #056fab; }
  .testimonial_bubble p {
    position: relative;
    top: 30px;
    margin-top: -30px;
    font-family: omnes_light;
    font-size: 1.125em;
    color: #999; }

.bubble_container {
  margin: 0 auto;
  width: 100%; }

.bubble_corner {
  position: relative;
  top: 45px;
  left: 60px;
  width: 38px;
  height: 30px;
  background: url(PortalUnauthImg/bubble_corner.png) 0 0 no-repeat;
  clear: both; }

.author {
  position: absolute;
  top: 40px;
  width: 200px; }
  .author li:first-child {
    color: #666; }
  .author li:nth-child(2) {
    font-size: 0.875em;
    color: #999; }

/* CONTACT STYLES
====================================================
==================================================== */
#slice_contact {
  padding: 60px 0;
  color: #fff;
  background: #3381b7; }
  #slice_contact h2 {
    margin-bottom: 10px;
    font-family: omnes_att_iilight_italic;
    font-size: 1.875em; }
  #slice_contact h5 {
    margin-bottom: 10px;
    font-family: omnes_att_iimedium;
    font-size: 0.6875em; }
  #slice_contact p {
    height: 50px;
    font-family: clearviewattlight;
    font-size: 1em;
    line-height: 1.25em; }
  #slice_contact button {
    padding: 15px 40px;
    font-family: clearviewattregular;
    color: #3381b7;
    background: #fff;
    border: 0;
    -webkit-border-radius: 6px;
    border-radius: 6px; }
    #slice_contact button a:hover {
      text-decoration: none; }

.follow_us li {
  float: left;
  margin-right: 10px; }

#cred_pages .navbar {
  margin-bottom: 0; }

.max_1000_width {
  margin: 0 auto;
  max-width: 1000px; }

#slice_login,
#slice_apply,
#slice_contact_us,
#slice_contact_thanks {
  margin: 0;
  padding: 0 0 80px 0;
  width: 100%;
  background-size: cover !important; }
  #slice_login h1,
  /* Robyn 6/21/16 #slice_apply h1,*/
  #slice_contact_us h1,
  #slice_contact_thanks h1 {
    margin: 30px 0 40px;
    font-family: omnes_att_iimedium;
    font-size: 2.625em; }
  #slice_login h2,
  /* Robyn 6/21/16 #slice_apply h2,*/
  #slice_contact_us h2,
  #slice_contact_thanks h2 {
    font-family: omnesatt_iiregular;
    font-size: 1.125em; }

#slice_login {
  height: 100%;
  background: url(PortalUnauthImg/hero_login.jpg) 0 0 no-repeat; }

#slice_apply {
  background: url(PortalUnauthImg/hero_apply.jpg) 0 0 no-repeat fixed; } /* Robyn 7/21/16: applied fixed attribute to class */

#slice_contact_us,
#slice_contact_thanks {
  background: url(PortalUnauthImg/hero_contact_us.jpg) 0 0 no-repeat; }

#slice_contact_thanks {
  padding-top: 80px; }
  #slice_contact_thanks h1 {
    font-family: omnes_att_iimedium_italic; }

.login_header,
/* Robyn 6/21/16 .apply_header,*/
.contact_header {
  margin: 60px 0;
  padding: 0 40px;
  text-align: center; }

/* Robyn 6/21/16 */
.form-heading {
  color: #fff;
}
.form-heading h1 {
  margin: 85px 0 25px 0;
  font-family: omnes_att_iimedium;
  font-size: 2.625em;
}
.form-heading p {
  margin: 0 0 85px 0;
  font-family: omnesatt_iiregular;
  font-size: 1.125em;
}
.form-body {
  background: #fff;
  padding: 40px 25px;
  border-radius: 4px;
}
/* END Robyn 6/21/16 */

.contact_thanks_header {
  margin: 30px 0;
  padding: 0 20px;
  text-align: center; }

.login_header {
  margin-top: 0;
  padding: 20px 0 40px 0;
  color: #fff;
  background-color: rgba(0, 0, 0, 0.7); }

.half_left_login,
.half_right_login,
.half_left_apply,
.half_right_apply {
  float: left;
  padding: 40px;
  min-height: 300px;
  height: auto;
  background: #fff;
  border: 2px solid #e5e5e5; }
  .half_left_login h2,
  .half_right_login h2,
  .half_left_apply h2,
  .half_right_apply h2 {
    text-align: left;
    width: 100%;
    margin-bottom: 15px; }

.half_left_login {
  margin-right: 4px;
  width: 60%; }
  .half_left_login img {
    float: left;
    width: 100%; }

.half_right_login {
  width: 39%; }

.login_container {
  margin: 0 auto;
  max-width: 1000px;
  height: 400px; }
  .login_container input {
    margin-bottom: 15px; }
  .login_container .btn-login {
    float: left;
    color: #fff;
    background: #056fab; }
    .login_container .btn-login:hover {
      color: #fff;
      background: #4f9ace; }

.forgot_pass {
  float: left;
  margin: 10px 0 0 5px;
  font-size: 0.75em; }

.half_left_apply {
  margin-right: 4px;
  width: 39%; }
  .half_left_apply img {
    float: left;
    width: 100%; }

.half_right_apply {
  width: 60%; }

.the_apply_form {
  width: 100%; }

.apply_zip {
  float: left; }

.apply_num_employees {
  float: none; }

.apply_business_type {
  margin-left: 20px; }

.label_yearly_revenue,
.apply_yearly_revenue {
  float: left;
  text-align: left;
  width: 100%; }

.label_yearly_revenue {
  margin: 10px 0; }

.current_programs,
.size_of_customer {
  margin: 20px 0;
  float: left;
  width: 100%;
  text-align: left; }
  .current_programs em,
  .size_of_customer em {
    margin-left: 5px;
    color: #0c9fd6;
    font-size: 0.875em; }
  .current_programs label,
  .size_of_customer label {
    margin-right: 10px;
    font-size: 0.75em; }
  .current_programs span,
  .size_of_customer span {
    position: relative;
    top: 4px; }

.provider_question {
  width: 100%;
  text-align: left; }

.provider_question_radio_group,
.end_user_support_radio_group,
.operations_center_radio_group,
.business_provide_radio_group,
.business_support_radio_group {
  float: left;
  height: 30px; }
  .provider_question_radio_group label,
  .end_user_support_radio_group label,
  .operations_center_radio_group label,
  .business_provide_radio_group label,
  .business_support_radio_group label {
    margin-right: 15px;
    font-size: 0.75em; }
  .provider_question_radio_group span,
  .end_user_support_radio_group span,
  .operations_center_radio_group span,
  .business_provide_radio_group span,
  .business_support_radio_group span {
    position: relative;
    top: 4px; }

.provider_question_radio_group {
  height: 20px; }

.apply_form_step_4 h4 {
  margin-bottom: 20px;
  text-align: left;
  font-size: 0.875em;
  line-height: 1.25em; }

.how_did_you_learn_about_us {
  margin-bottom: 20px;
  width: 100%;
  float: left; }

.apply_pager li {
  float: left;
  padding: 10px;
  color: #3381b7;
  background: #fff;
  border: 1px solid #ccc; }

.apply_pagination {
  margin-top: 40px;
  width: 100%;
  clear: both; }
  .apply_pagination p {
    font-size: 0.875em;
    line-height: 1.25em; }

.apply_form_step_1 {
  display: block; }

.apply_form_step_2 {
  display: none; }

.apply_last_optional {
  float: left;
  margin-bottom: 20px;
  padding-top: 20px;
  width: 100%;
  border-top: 1px solid #e5e5e5; }

.li_prev {
  display: none;
  margin-right: 20px; }

.submit_apply {
  display: none;
  float: right;
  margin-top: 5px;
  margin-right: 15px;
  font-size: 0.75em; }
  .submit_apply input {
    margin-right: 10px; }
  .submit_apply .btn-primary {
    margin-left: 15px; }

.apply_previous,
.apply_next {
  cursor: pointer;
  -webkit-border-radius: 4px;
  border-radius: 4px; }

.apply_previous {
  margin-right: 15px; }

.bootstrap-select.btn-group:not(.input-group-btn),
.bootstrap-select.btn-group[class*="col-"] {
  float: left; }

.contact_form_container {
  margin: 0 auto;
  padding: 40px;
  max-width: 700px;
  background: #fff; }
  .contact_form_container p {
    margin-bottom: 20px; }
  .contact_form_container input {
    margin-bottom: 15px; }
  .contact_form_container label {
    margin-bottom: 10px; }
  .contact_form_container .btn-login {
    float: right;
    color: #fff;
    background: #3381b7; }
    .contact_form_container .btn-login:hover {
      color: #fff;
      background: #4f9ace; }

.forgot_password_body {
  margin: auto;
  background-color: #fff;
  width: 95%;
  max-width: 420px;
  border: 2px solid #e5e5e5;
  min-height: 300px;
  padding: 40px; }
  .forgot_password_body .forgot_password_container h2 {
    margin-bottom: 8px; }
  .forgot_password_body .forgot_password_container input {
    margin-bottom: 15px; }
  .forgot_password_body .forgot_password_container .btn-login {
    float: left;
    color: #fff;
    background: #056fab; }
    .forgot_password_body .forgot_password_container .btn-login:hover {
      color: #fff;
      background: #4f9ace; }

.security_answer_body {
  margin: auto;
  background-color: #fff;
  width: 95%;
  max-width: 420px;
  border: 2px solid #e5e5e5;
  min-height: 300px;
  padding: 40px; }
  .security_answer_body .security_answer_container h2 {
    margin-bottom: 8px; }
  .security_answer_body .security_answer_container input {
    margin-bottom: 15px; }
  .security_answer_body .security_answer_container .btn-login {
    float: left;
    color: #fff;
    background: #056fab; }
    .security_answer_body .security_answer_container .btn-login:hover {
      color: #fff;
      background: #4f9ace; }

.update_password_body {
  margin: auto;
  background-color: #fff;
  width: 95%;
  max-width: 420px;
  border: 2px solid #e5e5e5;
  min-height: 300px;
  padding: 40px; }
  .update_password_body .update_password_container h2 {
    margin-bottom: 8px; }
  .update_password_body .update_password_container input {
    margin-bottom: 15px; }
  .update_password_body .update_password_container .btn-login {
    float: left;
    color: #fff;
    background: #056fab; }
    .update_password_body .update_password_container .btn-login:hover {
      color: #fff;
      background: #4f9ace; }

/* LAYOUT
====================================================
==================================================== */
#complete_registration {
  margin-top: 74px;
  margin-left: auto;
  margin-right: auto;
  padding: 40px 20px;
  max-width: 1170px; }
  #complete_registration h1 {
    font-size: 2.75em; }
  #complete_registration h2 {
    margin-bottom: 30px;
    font-size: 1.75em; }
  #complete_registration h3 {
    font-size: 1.125em; }
  #complete_registration h4 {
    margin-bottom: 10px;
    font-family: omnes_att_iilight_italic;
    font-size: 1.5em;
    color: #056fab; }
  #complete_registration strong {
    font-family: omnes_att_iimedium;}
  #complete_registration input {
    float: left;
    margin-bottom: 15px;
    padding: 0 10px;
    width: 100%;
    height: 32px;
    border: 1px solid #ccc;
    -webkit-border-radius: 4px;
    border-radius: 4px; }

.mobile_welcome {
  display: none; }

.user_id_table {
  margin-top: 30px;
  width: 290px; }
  .user_id_table td {
    padding-bottom: 10px; }

.complete_registration_content {
  margin: 40px auto; }
  .complete_registration_content li {
    margin: 10px 0 10px; }
  .complete_registration_content .css-label {
    float: left;
    margin-bottom: 30px;
    font-size: 0.75em !important; }

#check_newsletter {
  float: left; }

.styled-select select {
  background: transparent;
  width: 268px;
  padding: 5px;
  font-size: 16px;
  line-height: 1;
  border: 0;
  border-radius: 0;
  height: 34px;
  -webkit-appearance: none; }

.styled-select {
  width: auto;
  height: 34px;
  overflow: hidden;
  background: url(PortalUnauthImg/new_arrow.png) no-repeat right #fff;
  border: 1px solid #ccc;
  cursor: pointer;
  -webkit-border-radius: 4px;
  border-radius: 4px; }

.welcome_message_block {
  margin-left: 40px;
  padding: 40px;
  border: 1px solid #e1e1e1;
  background: #fff; }
  .welcome_message_block:after {
    content: "";
    display: table;
    clear: both; }
  .welcome_message_block ul {
    margin-top: 30px; }

.blue_circle {
  float: left;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  font-family: omnes_att_iilight_italic;
  text-align: center;
  line-height: 36px;
  color: #fff;
  background: #056fab; }

.welcome_point {
  float: right;
  margin-top: -30px;
  margin-left: 50px;
  margin-bottom: 20px;
  line-height: 1.25em; }

.welcome_arrow {
  position: relative;
  top: 125px;
  left: 17px; }

.complete_reg_desk {
  display: block; }

.complete_reg_mobile {
  display: none; }

.complete_registration_li {
  float: left;
  width: 100%; }
  .complete_registration_li button {
    padding: 10px 20px;
    color: #fff;
    background: #056fab;
    border: 0;
    -webkit-border-radius: 4px;
    border-radius: 4px; }
    .complete_registration_li button:hover {
      background: #068fdd; }

/* EMAILS
====================================================
==================================================== */
.att_email_body {
  max-width: 600px; }

.email_container {
  padding: 40px;
  width: 100%;
  height: auto;
  line-height: 1.5em;
  color: #333;
  background: #f7f7f7; }
  .email_container h1 {
    margin-bottom: 10px;
    font-size: 1.75em; }
  .email_container h2 {
    margin-bottom: 20px;
    font-family: omnes_att_iimedium; }
  .email_container em {
    color: #056fab; }
  .email_container button {
    margin-top: 40px;
    padding: 10px 20px;
    color: #fff;
    background: #056fab;
    border: 0;
    -webkit-border-radius: 4px;
    border-radius: 4px; }
    .email_container button:hover {
      background: #3bc1f4; }

.email_footer {
  padding: 0 60px 60px;
  background: #f7f7f7; }

.email_logo_row {
  padding: 20px 0; }

.navbar-brand-email {
  margin: 40px 0 40px 60px; }

/*  SVG background images
====================================================
==================================================== */
.hero_down,
.ico_program_members,
.ico_service_providers,
.ico_direct_platform,
.ico_app_developers,
.ico_wholesale,
.ico_software_vendors,
.ico_dash,
.ico_calendar,
.ico_battery,
.ico_home_sync,
.ico_stocks,
.ico_weather,
.ico_email,
.ico_eye,
.ico_weather,
.ico_stocks,
.ico_home_wifi,
.ico_close_x,
.ico_globe,
.ico_wifi,
.ico_cloud,
.ico_x,
.more_arr,
.more_arr_down,
.products_globe,
.products_wifi,
.products_cloud,
.blue_tri {
  position: relative;
  margin: 0 auto;
  background-size: 600px 600px;
  background-image: url(PortalUnauthImg/partner_exchange.svg), none; }

.dropdown_btn {
  background-size: 600px 600px;
  background-image: url(PortalUnauthImg/un_icons.svg), none; }

/*  RESPONSIVE MEDIA QUERIES
====================================================
==================================================== */
/* 1400
==================================================== */
@media all and (max-width: 1400px) {
  .what_we_do_copy,
  .what_we_do_copy_bg {
    right: -35%; } }
/* 1200
==================================================== */
@media all and (max-width: 1200px) {
  #slice_who_we_are h3 {
    font-size: 2em; }
  #slice_who_we_are p {
    font-size: 1.125em;
    line-height: 1.25em; }

  .copy_block_1 {
    top: 50px; }

  .copy_block_2 {
    top: 70px; }

  .copy_block_3 {
    top: 70px; }

  .what_we_do_copy,
  .what_we_do_copy_bg {
    right: -25%; } }
/* 1100
==================================================== */
@media all and (max-width: 1100px) {
  .modal_block {
    margin-top: 140px;
    padding-top: 70px;
    height: 270px; }

  .eco_subhead {
    display: none; }

  .down_blue_triangle {
    top: 5px; } }
/* 1060
==================================================== */
/* 1000
==================================================== */
@media all and (max-width: 1000px) {
  /* Robyn 6/13/16 comment out for logo update
  .navbar-logo {
    width: 50px;
    height: 50px;
    overflow: hidden; }*/
  .navbar-collapse.collapse {display: none !important;} /* Robyn 6/13/16: add break style for logo update */
  .navbar-collapse.collapse.in {display: block !important;}
  .navbar-toggle {display: block; margin-top: 15px;}
  .navbar-header {width: 100%;}
  .hero_col {
    width: 100%; }

  .desktop_view {
    display: none; }

  .ipad_view {
    display: block; }

  .copy_block {
    margin-top: 40px;
    max-width: 100%;
    height: 160px;
    text-align: left; }

  .copy_block_1 {
    top: 0px; }

  .copy_block_2 {
    top: 0px; }

  .copy_block_3 {
    top: 0px; }

  #slice_who_we_are .img-responsive {
    display: block;
    margin: 20px 0;
    width: 100%; }

  .what_we_do_copy,
  .what_we_do_copy_bg {
    right: 0; }

  #ca-container {
    display: none; }

  #products_mobile_size {
    display: block; }

  .view_all_products {
    width: 100%; }

  #all_products {
    background: #FFF;
    position: relative;
    top: -56px; }

  .all_products_container {
    width: 100%;
    top: 3px; }

  .bubble_container {
    margin: 0 auto;
    width: 80%; }

  .testimonial_bubble {
    margin: 0 0 50px 0;
    max-width: 100%;
    width: 100%; }

  .author {
    display: none; }

  .mobile_welcome {
    display: block; }

  .user_id_table {
    width: 100%; }

  .welcome_hide {
    display: none; } }
/* 960
==================================================== */
@media all and (max-width: 960px) {
  .ecosystem_header {
    padding-top: 40px; } }
/* 900
==================================================== */
@media all and (max-width: 900px) {
  #ecosystem_block {
    height: 560px; }

  .half_left_apply {
    display: none; }

  .half_right_apply {
    float: none;
    margin: 0 auto;
    width: 90%; } }
/* 850
==================================================== */
@media all and (max-width: 850px) {
  .modal_copy_1,
  .modal_copy_2,
  .modal_copy_3,
  .modal_copy_4,
  .modal_copy_5 {
    padding: 20px 20px 0 20px;
    width: 70%;
    height: 200px; }

  .modal_block {
    opacity: 1; }

  .ecosystem_header {
    padding-top: 30px; }
    .ecosystem_header h1 {
      font-size: 2em; }

  .ecosystem_header,
  .eco_tiles {
    width: 100%; }

  .top_icon {
    float: left;
    position: relative;
    top: -25px;
    margin-left: 20px; }

  .top_group {
    position: relative;
    top: -15px;
    margin: 0 auto;
    width: 100%; }
    .top_group h2 {
      position: relative;
      top: 10px;
      margin-left: 90px;
      text-align: left; }
    .top_group section {
      position: relative !important;
      top: 0 !important;
      left: 10% !important;
      margin-bottom: 10px !important;
      padding: 2px 0 !important;
      width: 80% !important;
      height: 70px !important;
      font-family: clearviewattregular;
      font-size: 1.125em !important;
      background: #044f79; }

  .mid_group,
  .videobg {
    display: none; }

  .modal_block {
    margin-top: 100px;
    margin-left: auto;
    margin-right: auto;
    padding: 80px 40px 0 40px;
    width: 80%;
    height: 240px; }
    .modal_block li {
      font-size: 1.25em;
      margin-bottom: 20px; }

  #all_products h2 {
    font-size: 1em;
    line-height: 1.25em; }

  .cloud_and_hosting {
    top: -5px; } }
/* 800
==================================================== */
@media all and (max-width: 800px) {
  .hero_badge,
  .hero_badge_bg {
    width: 100%; }

  #slice_hero h1 {
    font-size: 2em; }
  #slice_hero h2 {
    font-size: 1em; } }
/* 768 (Mobile Break)
==================================================== */
@media all and (max-width: 768px) {
  .navbar-toggle {margin-right: -15px;}
  .nav {
    top: 0px !important; }

  .login_nav .nav {
    top: -48px !important; }

  .half_left_login {
    display: none; }

  .half_right_login {
    float: none;
    margin: 0 auto;
    padding: 30px;
    width: 90%;
    min-height: 250px; }
    .half_right_login h2 {
      font-size: 1em; }

  .what_we_do_copy,
  .what_we_do_copy_bg {
    position: relative;
    padding: 20px 40px;
    width: 100%; }

  .what_we_do_copy h3 {
    margin: 30px 0 25px;
    font-size: 2em; }
  .what_we_do_copy p {
    font-family: omnesatt_iiregular;
    font-size: 1em; }

  #all_products h2 {
    font-size: 2em; }

  .pop_product {
    font-size: 1em; }

  .all_products_container {
    height: 100%; }

  .cloud_and_hosting {
    top: -10px; }

  #slice_footer footer {
    margin: 0 auto;
    width: 90%; }

  .login_nav .navbar-right {
    float: right !important; }

  .navbar-brand-email {
    top: 20px;
    left: 60px; } }
/* 700
==================================================== */
@media all and (max-width: 700px) {
  .what_we_do_copy h3 {
    margin: 30px 0 40px;
    font-size: 1.5em; }
  .what_we_do_copy p {
    font-family: omnesatt_iiregular;
    font-size: 1em; }

  .what_we_do_copy_bg {
    height: 240px; }

  #slice_contact {
    padding: 50px 20px; }
    #slice_contact h2 {
      margin-top: 20px; }
    #slice_contact p {
      margin-bottom: 10px;
      height: auto; }

  .follow_us {
    margin-top: 40px; } }
/* 640
==================================================== */
@media all and (max-width: 640px) {
  .navbar-logo {
    overflow: visible; }

  .product_smll h3 {
    margin-top: 20px; }

  .p_modal {
    left: 0;
    margin: 60px 0;
    padding: 10px;
    width: 100%; }
    .p_modal h1 {
      font-size: 1.5em; }

  .top_group h2 {
    font-size: 14px; } }
/* 600
==================================================== */
@media all and (max-width: 600px) {
  .direct_connect_large {
    display: none; }

  .direct_connect_small {
    display: block; }

  #all_products h2 {
    font-size: 1.5em; }

  .cloud_and_hosting {
    top: 0px; } }
/* 500
==================================================== */
@media all and (max-width: 500px) {
  .hero_badge,
  .hero_badge_bg {
    height: 180px; }

  .hero_badge_bg {
    top: -195px; }

  .hero_down {
    top: -32px; }

  .hero_badge {
    top: 0; }

  .apply_now_hero {
    top: 0; }

  #slice_hero h1 {
    font-size: 2em; }

  .copy_block {
    height: auto;
    padding: 0 10px; }

  .what_we_do_copy {
    padding: 10px 20px; }

  .what_we_do_copy_bg {
    position: relative;
    width: 100%; }

  #all_products h2 {
    font-size: 1.125em; } }
/* 360
==================================================== */