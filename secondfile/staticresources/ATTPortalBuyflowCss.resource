@charset "UTF-8";
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
|     |-- header
|     |-- 
|     ...
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
  font-weight: bold; }

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
b, u, i, center,
dl, dt, dd, ol, ul, li,
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
  font: inherit;
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
  src: url("PortalDesignFonts/omnes_light.eot");
  src: url("PortalDesignFonts/omnes_light.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/omnes_light.woff2") format("woff2"), url("PortalDesignFonts/omnes_light.woff") format("woff"), url("PortalDesignFonts/omnes_light.ttf") format("truetype"), url("PortalDesignFonts/omnes_att_ii_light-webfont.svg#omnes_att_iilight") format("svg");
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
  font-family: 'clearviewbold';
  src: url("PortalDesignFonts/clvatt-bold-webfont.eot");
  src: url("PortalDesignFonts/clvatt-bold-webfont.eot?#iefix") format("embedded-opentype"), url("PortalDesignFonts/clvatt-bold-webfont.woff2") format("woff2"), url("PortalDesignFonts/clvatt-bold-webfont.woff") format("woff"), url("PortalDesignFonts/clvatt-bold-webfont.ttf") format("truetype"), url("PortalDesignFonts/clvatt-bold-webfont.svg#clearviewattregular") format("svg");
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
.container {
  padding: 0 10px;
  width: 100%; }

.navbar-nav.navbar-right:last-child {
  margin-right: 10px; }

.navbar-default,
.navbar-default .navbar-collapse,
.navbar-default .navbar-form {
  border-color: #FFF;
  background: #FFF; }

.navbar-brand {
  margin-left: 0 !important; }

.navbar-toggle {
  margin-top: 15px; }

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

h1 {
  font-family: omnes_light;
  font-size: 2.625em;
  color: #666; }

button {
  margin: 0 10px;
  padding: 10px 20px;
  font-family: clearviewattregular;
  color: #fff;
  background: #056fab;
  border: 0;
  -webkit-border-radius: 4px;
  border-radius: 4px; }
  button:hover {
    background: #3bc1f4; }

button.secondary {
  color: #056fab;
  background: #fff;
  border: 1px solid #e5e5e5; }
  button.secondary:hover {
    background: #e5e5e5; }

li {
  list-style: none; }

a:hover {
  text-decoration: none !important; }

.btn:hover {
  text-decoration: none; }

.slice {
  padding: 60px 0; }

.hero_message {
  margin-top: 100px;
  padding: 20px;
  width: 65%;
  background-color: rgba(255, 255, 255, 0.7); }
  .hero_message h1 {
    margin-bottom: 10px;
    position: relative;
    top: 20%;
    font-family: omnes_att_iilight_italic;
    font-size: 2.75em; }
  .hero_message h2 {
    font-size: 1.125em;
    color: #666; }

.gray_bg {
  background: #f7f7f7; }

.blue_button {
  padding: 10px 40px;
  color: #fff;
  border: 0;
  background: #056fab;
  -webkit-border-radius: 4px;
  border-radius: 4px; }
  .blue_button:hover {
    background: #068fdd; }

input[type=checkbox].css-checkbox {
  position: absolute;
  overflow: hidden;
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
  vertical-align: middle;
  cursor: pointer; }

input[type=checkbox].css-checkbox:checked + label.css-label,
input[type=checkbox].css-checkbox + label.css-label.chk {
  background-position: 0 -17px; }

label.css-label {
  background-image: url(portalDesignImg/csscheckbox.png);
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none; }

table a {
  color: #3bc1f4; }

.styled-select select,
.styled-select-small select {
  background: transparent;
  width: 100%;
  padding: 5px;
  line-height: 1;
  border: 0;
  border-radius: 0;
  height: 34px;
  -webkit-appearance: none; }

.styled-select,
.styled-select-small {
  width: auto;
  overflow: hidden;
  border: 1px solid #ccc;
  cursor: pointer;
  -webkit-border-radius: 4px;
  border-radius: 4px; }

.styled-select {
  height: 32px;
  font-size: 1em;
  background: url(portalDesignImg/new_arrow.png) no-repeat right #fff; }

.styled-select-small {
  height: 26px;
  background: url(portalDesignImg/new_arrow_small.png) no-repeat right #fff; }

.css-check-label {
  margin-top: 20px;
  font-size: 0.875em !important; }

.dashed_hr {
  margin: 40px 0;
  border-bottom: 1px dashed #ccc; }

strong {
  font-family: omnes_att_iimedium; }

sup, sub {
  font-size: 75%;
  line-height: 0;
  vertical-align: baseline; }

sup {
  top: -0.5em;
  left: 0.15em; }

sub {
  bottom: -0.25em; }

input.input_error {
  border: 1px solid #d23939 !important;
  background: #fef3f1; }

label.input_error, p.input_error {
  color: #d23939; }

p.input_error {
  font-size: 0.75em; }

.font12 {
  font-size: 0.75em; }

.dataTable {
  width: auto; }

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
    font-family: omnes_att_iilight_italic;
    font-size: 1.75em;
    color: #056fab;
    margin-bottom: 20px;
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
    margin: 25px 20px 0px 8px;
    font-size: 32px;
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
    margin: 0px 2px; }

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

/* INPUTS & SELECTS
====================================================
==================================================== */
input[type=checkbox].css-checkbox {
  position: absolute;
  overflow: hidden;
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
  vertical-align: middle;
  cursor: pointer; }

input[type=checkbox].css-checkbox:checked + label.css-label,
input[type=checkbox].css-checkbox + label.css-label.chk {
  background-position: 0 -17px; }

label.css-label {
  background-image: url(portalDesignImg/csscheckbox.png);
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none; }

table a {
  color: #3bc1f4; }

.styled-select select,
.styled-select-small select {
  background: transparent;
  width: 100%;
  padding: 5px;
  line-height: 16px;
  border: 0;
  border-radius: 0;
  height: 27px;
  -webkit-appearance: none;
  cursor: pointer; }

.styled-select,
.styled-select-small {
  width: auto;
  overflow: hidden;
  border: 1px solid #ccc;
  cursor: pointer;
  -webkit-border-radius: 4px;
  border-radius: 4px; }

.styled-select {
  height: 32px;
  font-size: 1em;
  background: url(portalDesignImg/new_arrow.png) no-repeat right #fff; }

.styled-select-small {
  height: 26px;
  background: url(portalDesignImg/new_arrow_small.png) no-repeat right #fff; }

.adjust-select {
  position: relative;
  top: -11px; }

.adjust-select-small {
  width: 160px; }

.css-check-label {
  margin-top: 20px;
  font-size: 0.875em !important; }

/* LAYOUT
====================================================
==================================================== */
#top_nav_bar .search_button {
  float: none;
  top: 13px;
  left: 0; }

#nav_desktop {
  margin-top: 10px; }
  #nav_desktop li {
    margin-right: -5px; }

.att_partner_exchange_logo {
  width: 242px;
  height: 34px; }

.begin_quote_btn {
  margin-top: -10px;
  padding: 1px 14px 0px 10px;
  font-family: clearviewattlight;
  font-size: 0.875em;
  line-height: 40px;
  color: #fff;
  border: 0;
  background: #056fab;
  -webkit-transition: background 0.2s ease-in-out;
  -ms-transition: background 0.2s ease-in-out;
  -o-transition: background 0.2s ease-in-out;
  transition: background 0.2s ease-in-out;
  -webkit-border-radius: 3px;
  border-radius: 3px; }
  .begin_quote_btn:after {
    content: "";
    display: table;
    clear: both; }
  .begin_quote_btn:hover {
    background: #3bc1f4; }

.navbar-header {
  margin-top: 5px; }

.begin_quote_icon {
  float: left;
  width: 34px;
  height: 39px;
  background-position: -10px -80px; }

/*.user_badge {
  margin-top: -10px; }*/

.avatar,
.user_welcome {
  float: left; }

.user_welcome {
  margin-left: 10px;
  font-size: 0.75em;
  line-height: 1.25em; }

.unactive_top:hover {
  color: #3bc1f4 !important; }

.active_top {
  position: relative;
  top: 1px;
  height: 62px;
  color: #fff !important;
  background: #056fab !important; }
  .active_top:hover {
    color: #fff !important;
    background: #056fab !important; }

.sub_navigation {
  margin-top: 70px;
  font-family: "omnesatt_iiregular";
  color: #fff;
  display: block;
  height: 0px;
  width: 100%;
  background: #056fab;
  overflow: hidden; }

.sub_content {
  margin: 0 auto;
  padding: 40px 40px 20px 40px; }

.grow-content,
.products-content,
.manage-content,
.connect-content {
  height: auto;
  display: none; }

.sub_links_container {
  margin: 0 auto;
  padding: 0;
   max-width: 80%; }

.sub_links_products {
  width: 1080px; }

.sub_links_manage {
  width: 700px; }

.link-section {
  float: left;
  margin-right: 30px;
  margin-bottom: 30px; }
  .link-section:after {
    content: "";
    display: table;
    clear: both; }
  .link-section h4 {
    font-family: omnes_att_iilight_italic;
    font-size: 1.5em;
    color: #b9ddf9;
    margin-bottom: 5px;
    margin-top: 0px; }
  .link-section ul {
    margin-top: 20px; }
  .link-section li {
    margin-bottom: 10px;
    display: block; }
    .link-section li a {
      color: #fff; }
  .link-section:last-child {
    margin-right: 0; }

/* PROFILE
====================================================
==================================================== */
#profile_content {
  margin: 0 auto 60px;
  padding: 40px;
  max-width: 1168px; }
  #profile_content h1 {
    margin-bottom: 10px;
    font-size: 2.625em; }
  #profile_content h3 {
    font-family: omnes_att_iimedium;
    font-size: 1.25em; }
  #profile_content input {
    float: left;
    margin-bottom: 15px;
    padding: 0 10px;
    width: 100%;
    height: 32px;
    border: 1px solid #ccc;
    -webkit-border-radius: 4px;
    border-radius: 4px; }
  #profile_content label {
    margin-bottom: 10px; }
  #profile_content button {
    margin-top: 20px;
    padding: 15px 40px; }
  #profile_content .optional_permissions_table h3 {
    margin-top: -3px; }

.profile_header {
  margin-bottom: 40px; }

.profile_photo {
  margin-bottom: 20px; }

#current_avatar {
  width: 200px;
  cursor: pointer; }

#choose_file {
  position: relative;
  top: -10px;
  left: 30px;
  width: 230px !important;
  border: none;
  z-index: 1; }

.upload_photo {
  float: left;
  position: relative;
  margin-right: 34px;
  width: 24px;
  height: 17px;
  background-position: -40px -63px;
  z-index: 2;
  top: -50px; }

.upload_p {
  float: left;
  margin-left: 10px;
  display: block;
  position: relative;
  top: -75px;
  left: 20px;
  padding: 10px 10px 10px 0;
  width: 230px;
  color: #006497;
  background: #f7f7f7;
  cursor: pointer;
  z-index: 2; }

.profile_row {
  margin-bottom: 60px; }

.profile_table_form {
  margin-bottom: 30px;
  width: 290px; }

.question_icon {
  float: right;
  position: absolute;
  top: 370px;
  right: 21px;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 0.875em;
  line-height: 1.25em;
  text-align: center;
  color: #056fab;
  background: #fff;
  border: 1px solid #ccc;
  cursor: pointer; }

.notification_col {
  float: right;
  width: 36.66%; }

.my_notifications {
  padding: 20px;
  background: #fff;
  border: 1px solid #ccc; }
  .my_notifications hr {
    border-bottom: 1px dashed #ccc; }
  .my_notifications h4 {
    line-height: 1.375em; }
  .my_notifications ul {
    margin-top: 40px; }
  .my_notifications p {
    margin-left: 46px;
    margin-bottom: 20px; }

.optional_permissions,
.optional_permissions_mobile {
  background: #fff; }

.optional_permissions_mobile {
  display: none; }
  .optional_permissions_mobile h3 {
    margin-bottom: 20px; }
  .optional_permissions_mobile .mobile_label {
    font-size: 0.875em !important; }
  .optional_permissions_mobile h4 {
    margin-bottom: 10px; }

/* COMPLETE REGISTRATION
====================================================
==================================================== */
#complete_registration_form button {
  margin-top: 40px; }
#complete_registration_form .question_icon {
  top: 405px; }

.welcome_message {
  float: right;
  position: relative;
  width: 70%;
  z-index: 2; }

.blue_bullet {
  width: 100%;
  min-height: 40px; }
  .blue_bullet h3 {
    float: left;
    font-family: omnes_att_iilight_italic !important;
    color: #056fab; }

.blue_circle {
  float: left;
  margin: 0 10px 0 0;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  line-height: 36px;
  text-align: center;
  color: #fff;
  background: #056fab; }

.left_wedge {
  float: left;
  position: relative;
  top: 70px;
  left: 51px;
  width: 21px;
  height: 40px;
  background-position: 0 -120px;
  z-index: 3; }

/* DASHBOARD
====================================================
==================================================== */
#dashboard_container {
  background: #e5e5e5; }
  #dashboard_container img {
    width: 100%; }

/* HEROES
====================================================
==================================================== */
#hero_banner {
  margin: 0;
  padding: 0;
  width: 100%;
  background-repeat: no-repeat;
  background-position: center;
  background-size: cover; }

.hero_products {
  height: 388px;
  background-image: url("portalDesignImg/heros/products.jpg"); }

.hero_manage {
  height: 99px;
  background-image: url("portalDesignImg/heros/products.jpg") !important; }

/* PRODUCTS
====================================================
==================================================== */
#products_content {
  max-width: 1168px;
  margin: 0 auto; }

#products_content {
  margin: 60px auto; }
  #products_content section {
    margin-bottom: 40px; }
  #products_content h1 {
    margin-bottom: 10px;
    font-size: 2.625em; }
  #products_content p {
    margin: 10px auto;
    line-height: 1.25em; }
  #products_content ul {
    margin-left: 20px;
    list-style: disc;
    line-height: 1.25em; }
  #products_content .active {
    box-shadow: none; }

.products_left_nav {
  width: 153px;
  padding-top: 10px; }
  .products_left_nav button {
    width: 100%;
    display: block;
    font-size: 1.1em;
    text-align: left;
    color: #009add; }
  .products_left_nav button.active {
    background-color: #009add;
    color: #fff; }

.sticky {
  position: fixed;
  /* width: 100%; */
  left: 40px;
  top: 100px;
  z-index: 10001;
  border-top: 0; }

.load-product-content .overview li {
  list-style: disc; }

/*
PRODUCTS - TRAINING PAGE STYLE
===================================================
*/
.training .product-icon {
  width: 20%;
  float: left; }
.training .details {
  width: 80%;
  float: right; }
.training section {
  background-color: #fff;
  padding: 40px;
  border: 1px solid #e9e9e9;
  margin-bottom: 20px; }
  .training section:after {
    content: "";
    display: table;
    clear: both; }
  .training section .title {
    font-size: 1.125em !important;
    margin-bottom: 16px !important;
    color: #009add; }
  .training section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; }
  .training section ul {
    text-indent: 31px;
    list-style: none; }
  .training section li {
    list-style: none;
    margin-bottom: 7px; }
  .training section ul li:before {
    content: "•";
    margin-right: 9px; }
  .training section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }

/*
PRODUCTS - PRICING PAGE STYLE
===================================================
*/
.pricing .icon {
  width: 20%;
  float: left; }
.pricing .details {
  width: 80%;
  float: right; }
.pricing section {
  background-color: #fff;
  padding: 40px;
  border: 1px solid #e9e9e9; }
  .pricing section:after {
    content: "";
    display: table;
    clear: both; }
  .pricing section .title {
    font-family: "omnes_att_iimedium" !important;
    font-size: 1.125em !important;
    margin-bottom: 0px !important;
    color: #009add; }
  .pricing section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; }
  .pricing section ul {
    text-indent: 31px;
    list-style: none !important; }
  .pricing section li {
    list-style: none !important;
    margin-bottom: 7px !important; }
  .pricing section ul li:before {
    content: "•";
    margin-right: 9px; }
  .pricing section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }

/*
PRODUCTS - DOCUMENTATION PAGE STYLE
===================================================
*/
.documentation .row {
  padding: 0px !important;
  margin-bottom: 0px !important; }
.documentation .icon {
  width: 20%;
  float: left;
  margin-right: 10px; }
.documentation .details {
  width: 77%;
  float: left; }
.documentation section {
  background-color: #fff;
  border: 1px solid #e9e9e9;
  margin-bottom: 20px !important;
  margin-right: 20px;
  padding: 20px;
  width: 47%; }
  .documentation section .title {
    font-family: "omnes_att_iimedium" !important;
    font-size: 1.125em !important;
    margin-bottom: 0px !important;
    color: #009add; }
  .documentation section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; }
  .documentation section ul {
    text-indent: 31px;
    list-style: none !important; }
  .documentation section li {
    list-style: none !important;
    margin-bottom: 7px !important; }
  .documentation section ul li:before {
    content: "•";
    margin-right: 9px; }
  .documentation section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }

/*
PRODUCTS - RESOURCES PAGE STYLE
===================================================
*/
.resources .row {
  padding: 0px !important;
  margin-bottom: 0px !important; }
.resources .icon {
  width: 20%;
  float: left;
  margin-right: 10px; }
.resources .details {
  width: 77%;
  float: left; }
.resources section {
  margin-bottom: 30px !important; }
  .resources section .title {
    font-family: "omnes_att_iimedium" !important;
    font-size: 1.125em !important;
    margin-bottom: 5px !important;
    color: #009add; }
  .resources section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; }
  .resources section ul {
    text-indent: 31px;
    list-style: none !important; }
  .resources section li {
    list-style: none !important;
    margin-bottom: 7px !important; }
  .resources section ul li:before {
    content: "•";
    margin-right: 9px; }
  .resources section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }

/* MANAGE
====================================================
==================================================== */
#manage_content {
  margin: 0 auto 60px;
  padding: 40px;
  max-width: 1168px; }
  #manage_content h1 {
    margin-bottom: 10px;
    font-size: 2.625em; }
  #manage_content h2 {
    font-size: 1.5em;
    color: #ef6f00; }
  #manage_content h3 {
    font-size: 1.5em; }
  #manage_content label {
    margin: 10px 0;
    font-family: omnes_att_iimedium; }
  #manage_content input {
    float: left;
    padding: 0 10px;
    width: 100%;
    height: 32px;
    border: 1px solid #ccc;
    -webkit-border-radius: 4px;
    border-radius: 4px; }
  #manage_content .pagination {
    float: right; }
    #manage_content .pagination span {
      margin-right: 15px; }
    #manage_content .pagination button {
      padding: 5px 10px;
      font-family: omnes_att_iimedium;
      line-height: 1.125em;
      color: #056fab;
      background: #fff;
      border: 1px solid #ccc; }
    #manage_content .pagination .diabled {
      color: #666; }

/* Manage User
==================================================== */
.manage_user_search_row {
  margin-top: 40px;
  width: 100%; }

.search_user_container {
  float: left;
  width: 290px; }
  .search_user_container label {
    margin-bottom: 5px; }

#search_input {
  height: 40px !important; }

.search_button {
  float: right;
  top: -33px;
  right: 6px;
  width: 30px;
  height: 25px;
  background: #fff;
  background-position: -205px -47px;
  -webkit-border-top-right-radius: 4px;
  -webkit-border-bottom-right-radius: 4px;
  -moz-border-radius-topright: 4px;
  -moz-border-radius-bottomright: 4px;
  border-top-right-radius: 4px;
  border-bottom-right-radius: 4px;
  cursor: pointer; }
  .search_button:hover {
    opacity: .8; }

.create_users_button {
  float: right; }
  .create_users_button a {
    color: #fff; }

.manage_users_table {
  border: 1px solid #ccc;
  -webkit-border-radius: 4px;
  border-radius: 4px; }
  .manage_users_table table {
    width: 100%;
    font-size: 0.75em; }
  .manage_users_table thead td {
    padding: 0 2px 0 10px;
    border-bottom: 1px dashed #ccc;
    background: #fff; }
  .manage_users_table thead a {
    cursor: pointer; }
  .manage_users_table thead label {
    width: 100%; }
  .manage_users_table tbody tr {
    height: 26px;
    line-height: 24px;
    border-bottom: 1px dotted #CCC; }
  .manage_users_table tbody tr:nth-child(even) {
    background: #f9f9f9; }
  .manage_users_table td {
    padding-left: 10px;
    border-right: 1px solid #ccc; }
  .manage_users_table input {
    padding: 0 10px; }
  .manage_users_table .css-checkbox {
    margin: 0 10px;
    padding: 0 10px; }
.manage_users_table_container {
  border: 1px solid #ccc;
  -webkit-border-radius: 5px;
  border-radius: 5px; }
  .manage_users_table_container table {
    width: 100%;
    font-size: 1em; }
  .manage_users_table_container thead td {
    padding: 5px 2px 0 10px;
    border-bottom: 1px dashed #ccc;
    background: #fff; }
  .manage_users_table_container thead a {
    cursor: pointer; }
  .manage_users_table_container thead label {
    width: 100%; }
  .manage_users_table_container tbody tr {
    height: 26px;
    line-height: 24px;
    border-bottom: 1px dotted #CCC; }
  .manage_users_table_container tbody tr:nth-child(even) {
    background: #f9f9f9; }
  .manage_users_table_container td {
    padding-top: 5px;
    padding-left: 10px;
    border-right: 1px solid #ebebeb; }
  .manage_users_table_container input {
    padding: 0 10px; }
  .manage_users_table_container .css-checkbox {
    margin: 0 10px;
    padding: 0 10px; }
/*
  jquery.dataTables.min.js
  For sorting table data
*/
#manage_users_table_length,
#manage_users_table_filter,
#manage_users_table_info,
#manage_users_table_paginate {
  display: none; }

.check_col {
  width: 48px;
  height: 35px; }

.check-label {
  margin-left: 15px;
  margin-bottom: 5px; }

.manage_user_name {
  width: 30%; }

.manage_user_email {
  width: 40%; }

.reorder_btn {
  position: relative;
  top: -15px;
  margin-right: 10px !important;
  width: 18px;
  height: 18px;
  background-position: -40px -40px;
  cursor: pointer; }

.td_dropdown_arrow,
.td_down_arrow {
  position: relative;
  top: -10px;
  margin-right: 10px !important;
  height: 8px;
  cursor: pointer; }

.td_dropdown_arrow {
  width: 16px;
  background-position: -64px -40px; }

.td_down_arrow {
  width: 12px;
  background-position: -60px -50px; }

.status_more_options {
  position: absolute;
  top: 45px;
  right: 15px;
  padding: 10px 20px 20px 20px;
  font-size: 0.75em;
  border-left: 1px solid #ccc;
  border-right: 1px solid #ccc;
  border-bottom: 1px solid #ccc;
  background: #fff; }
  .status_more_options button {
    margin-top: 10px; }

.btn_deactivate_user {
  margin-top: 20px; }

/* Create User
==================================================== */
.basic_portal_access {
  margin: 40px 0 25px; }
  .basic_portal_access h3 {
    margin-bottom: 10px; }
  .basic_portal_access ul {
    margin: 10px 0 10px 20px; }
  .basic_portal_access li {
    list-style: disc;
    line-height: 1.375em; }
  .basic_portal_access p {
    margin-top: 20px; }

.optional_permissions table {
  width: 100%; }

.optional_permissions_table {
  width: 100%;
  border: 1px solid #ccc; }
  .optional_permissions_table header {
    position: relative;
    top: 10px; }
  .optional_permissions_table td {
    padding: 20px; }
  .optional_permissions_table h3 {
    float: left;
    margin-top: 5px; }
  .optional_permissions_table h4 {
    font-size: 1.25em;
    color: #056fab; }
  .optional_permissions_table li {
    line-height: 1.5em; }
  .optional_permissions_table .td_sub_headers td {
    padding-bottom: 0; }
  .optional_permissions_table .td_body_options td {
    padding: 10px 15px 20px; }
  .optional_permissions_table .bullets {
    margin-left: 28px;
    font-size: 0.75em;
    color: #999; }
  .optional_permissions_table .hr {
    width: 100%;
    border-bottom: 1px dashed #ccc; }

.btn_create_user {
  margin-top: 20px; }

.td_hr {
  padding: 0 !important;
  padding-top: 10px !important; }

.optional_permissions_checkgroup {
  float: left;
  margin-left: 10px; }

.optional_permission_options label {
  font-family: clearviewattregular;
  font-size: 0.875em !important; }

.has_r_border {
  padding-right: 30px;
  border-right: 1px solid #e5e5e5; }

.add_new_customer_header {
  margin-bottom: 40px; }

.dashed_hr {
  height: 0px;
  border-bottom: 1px dashed #ccc;
  background: transparent; }

.add_sites_tbody input {
  width: 95% !important;
  height: 24px !important; }

.added_sites_tbody {
  font-size: 0.875em; }

.add_site_btn {
  position: relative;
  top: -8px;
  padding: 4px 10px;
  width: 100px;
  font-size: 0.875em; }

.add_customer_complete_row {
  margin-top: 40px; }
  .add_customer_complete_row button, .add_customer_complete_row p {
    float: left; }
  .add_customer_complete_row p {
    margin-top: 10px;
    margin-left: 10px; }

.add_site_input_div {
  position: relative; }
  .add_site_input_div .styled-select-small {
    float: left;
    width: 60%;
    height: 25px; }
    .add_site_input_div .styled-select-small select {
      height: 25px; }
  .add_site_input_div .adjust-select-small {
    float: left;
    top: 0 !important;
    width: 100px; }

.add_site_location_adjust {
  position: relative;
  top: 2px; }

#add_site_location {
  float: left;
  margin-left: 10px;
  width: 40% !important; }
.adjust-select {
  position: relative;
  top: -8px; }

.adjust-select-small {
  position: relative;
  top: 8px;
  width: 160px; }

.business_profile_header {
  margin-bottom: 40px; }

/* Manage Quotes & Order
==================================================== */
.manage_quotes_order,
.manage_quotes_customer {
  width: 15% !important; }

.manage_quotes_modified {
  width: 11% !important; }

.manage_quotes_actions {
  width: 17% !important; }

.manage_quotes_type,
.manage_quotes_status,
.manage_quotes_products {
  width: 10% !important;
  background: #edf8fd !important; }

.progress_2 {
  background-position: 0 -11px; }

.progress_1 {
  background-position: 0 -22px; }

.manage_quotes_progress {
  text-align: center; }
  .manage_quotes_progress ul {
    max-width: 80px; }

/* BEGIN QUOTE
====================================================
==================================================== */
.tabbed_menu {
  position: relative;
  margin-top: 40px;
  z-index: 1000; }
  .tabbed_menu li {
    float: left;
    padding: 20px 50px;
    background: #fff;
    cursor: pointer; }
    .tabbed_menu li:hover {
      color: #3bc1f4; }
  .tabbed_menu li.active_tab:first-child {
    -webkit-border-top-left-radius: 4px;
    -moz-border-radius-topleft: 4px;
    border-top-left-radius: 4px; }
  .tabbed_menu li:last-child {
    -webkit-border-top-right-radius: 4px;
    -moz-border-radius-topright: 4px;
    border-top-right-radius: 4px; }
  .tabbed_menu li.active_tab {
    color: #fff;
    background: #056fab;
    -webkit-transition: background 0.2s ease-in-out;
    -ms-transition: background 0.2s ease-in-out;
    -o-transition: background 0.2s ease-in-out;
    transition: background 0.2s ease-in-out; }
    .tabbed_menu li.active_tab:hover {
      background: #068fdd; }
    .tabbed_menu li.active_tab:after {
      position: absolute;
      top: 56px;
      left: 105px;
      content: "";
      width: 0;
      height: 0;
      border-style: solid;
      border-width: 10px 20.5px 0 20.5px;
      border-color: #056fab transparent transparent transparent; }

.page_count {
  float: right;
  margin: 30px 10px 0 0; }

.begin_quote_checks {
  width: 40px !important;
  padding-right: 15px !important; }

.blue_hr {
  height: 2px;
  background: #056fab; }

.begin_quote_buttons {
  float: right; }

/* FOOTER STYLES
====================================================
==================================================== */
#slice_footer {
  margin: 60px auto;
  font-family: Arial, sans-serif;
  font-size: 0.75em;
  line-height: 1.25em; }

/*  SVG background images
====================================================
==================================================== */
.att_partner_exchange_logo,
.begin_quote_icon,
.search_button,
.reorder_btn,
.td_dropdown_arrow,
.td_down_arrow,
.upload_photo,
.left_wedge {
  position: relative;
  margin: 0 auto;
  background-size: 600px 600px;
  background-image: url(portalDesignImg/app_icons.svg), none; }

/*  SVG background images
====================================================
==================================================== */
.progress_full,
.progress_2,
.progress_1,
.progress_emtpy {
  position: relative;
  margin: 10px auto 5px;
  width: 82px;
  height: 11px;
  background-size: 82px 44px;
  background-image: url(portalDesignImg/quote_progress.png), none; }

    .br1 { border: 1px solid #ddd; }
    .manage_users_table_container tbody tr:nth-child(odd) { background: #f7f7f7; }
    #selectsite { background: none !important; }
    
    #addnewsite { background: none !important; }
    #addmultisite { background: none !important; }
    #enteraddresstabs .nav-tabs { border-bottom: 3px solid #0078b9; }
    #enteraddresstabs .manage_users_table_container { border-right: 0; border-left: 0; }
    #enteraddresstabs .nav-tabs li { width: 33.33%; text-align: center; }
    #enteraddresstabs .nav-tabs>li.active>a, .nav-tabs>li.active>a:hover, .nav-tabs>li.active>a:focus{ color: #fff !important; }
    .nav-tabs>li>a { line-height: inherit !important; }
    .m0 { margin: 0; }
    .m10 { margin: 10px; }
    
    .m-t-10 { margin-top: 10px; }
    .m-t-20 { margin-top: 20px; }
    .m-b-10 { margin-bottom: 10px; }
    .m-b-20 { margin-bottom: 20px; }
    .m-r-10 { margin-right: 10px; }
    .m-l-10 { margin-left: 10px; }
    .p0 { padding: 0; }
    .p10 { padding: 10px; }
    .p-b-10 { padding-bottom: 10px; }
    .p-t-10 { padding-top: 10px; }
    .w40p { width: 40%; }
    
    button, html input[type="button"], input[type="reset"], input[type="submit"] { margin: 0 10px; padding: 10px 20px; font-family: clearviewattregular !important; color: #fff; background: #056fab; border: 0 !important; -webkit-border-radius: 4px !important; border-radius: 4px !important; width: auto !important;
    }    
    input[type="radio"], input[type="checkbox"] { height: auto !important; width: auto !important; }
    #addedsites h4 { color: #ef6f00; }
    #addedsites h5 { color: #3bc1f4; }
    #addedsites #selectall { background: #fff; margin-top: 10px; padding: 10px; border: 1px solid #ddd; border-bottom: none; }     
    #addedsitescontainer { margin-top: 20px; background: #fff !important; height: 370px; overflow-y: auto; border: 1px solid #ddd; }
    #addedsitescontainer .list-group { border-bottom: 1px dashed #ddd; padding: 10px; margin-bottom: 0; }
    .circlebr1 { border-radius: 50%; width: 15px; height: 15px; padding: 7px 10px border: 1px solid #fff; }
    
    h1 { font-family: omnesatt_iiregular; }
    #selectproducts h4 { font-family: 'omnes_att_iimedium_italic'; color: #017ab1; font-size: 19px; }
    #selectterm td { width: 100px; }
    #selectterm input { float: left; margin-top: 3px !important; margin-right: 10px; width: auto; }
    #selectterm label { float: left; padding-left: 10px !important; padding-right: 15px !important; }
    #productheader label { float: left; margin-right: 10px; }
    #productheader input { float: left; margin: -6px 0 0 10px !important; width: 150px; }
    #productheader a { float: left; width: 40px; text-align: center; }
    #productoptions span{ display: block; margin-bottom: 20px; }
    #productoptions li input { margin-right: 10px !important; } /* Eliza 06/07/16 to fix space on buyflow page select product radio button */
    .active .circlenum { float: left; margin: -4px 7px 0 0; width:25px; height:25px; border-radius:15px; font-size:18px; color: #fff; line-height:25px; text-align:center; border: 1px solid #fff; }
    .circlenum { float: left; margin: -4px 0 0 0; width:25px; height:25px; border-radius:15px; font-size:10px; color: #428bca; line-height:25px; text-align:center; border: 1px solid #428bca; }
    #addSiteTabs .active { background: #056fab; color: #fff !important; }
    #addSiteTabs li { background: #fff; color: #056fab !important; }
    #addSiteTabs .active a { color: #fff; }
    .siteAddressValidateBtn { padding: 7px 20px ! important; width: auto; position: absolute; bottom: 20px; right: 10px;}
/*  RESPONSIVE MEDIA QUERIES
====================================================
==================================================== */
/* 1600
==================================================== */
/* 1400
==================================================== */
/* 1300
==================================================== */
/* 1260
==================================================== */
/* 1200
==================================================== */

  .tabbed_menu li {
    padding: 20px 40px; } }
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
      .tabbed_menu li {
    padding: 20px 30px; } }
/* 1000
==================================================== */
@media all and (max-width: 1000px) {
  .container {
    padding: 0 20px;
    width: 100% !important; }

  .user_welcome {
    display: none; }

  .hero_col {
    width: 100%; }

  table {
    font-size: 0.6875em !important; }

  .reorder_btn {
    display: none; } }
/* 990
==================================================== */
@media all and (max-width: 990px) {
  #nav_desktop,
  .container,
  .navbar-default .navbar-collapse {
    height: 70px !important; }

  .begin_quote_btn {
    width: 43px;
    height: 40px;
    overflow: hidden; }

  .tabbed_menu li {
    padding: 21px 20px;
    font-size: 0.875em; }
  .tabbed_menu li.active_tab:after {
    top: 56px;
    left: 70px !important; }

  .upload_p {
    top: -60px;
    left: -4px; }

  .notification_col {
    margin-top: 40px;
    width: 100%; }

  #choose_file {
    float: none !important; }

  .optional_permissions {
    display: none; }

  .optional_permissions_mobile {
    display: block; }

  .optional_permissions_mobile {
    border: 1px solid #ccc;
    padding: 20px; }
    .optional_permissions_mobile header {
      top: 5px; }

  .optional_permissions_table {
    border: 0; }
    .optional_permissions_table td {
      padding: 0px; }

  .optional_permissions_checkgroup label {
    font-size: 0.875em; }

  .welcome_message {
    margin-top: 40px;
    width: 100%; }

  .profile_row .left_wedge {
    display: none; }

  #complete_registration_form .question_icon {
    top: 398px; } }
/* 900
==================================================== */
@media all and (max-width: 900px) {
  .begin_quote_btn {
    width: 43px;
    height: 40px;
    overflow: hidden; } }
/* 850
==================================================== */
/* 800
==================================================== */
/* 768 (Mobile Break)
==================================================== */
@media all and (max-width: 768px) {
  .navbar-logo {
    width: auto;
    height: auto;
    overflow: hidden; }

  .nav {
    top: 0px !important; }

  .navbar-nav > li > a {
    line-height: 14px !important; }
 /*
  	Bootstrap override
  	http://stackoverflow.com/questions/26389771/mobile-menu-toggle-bug-after-changing-bootstraps-mobile-nav-break-point/26392195#26392195
  */
  .navbar-header {
    float: none; }

  .navbar-toggle {
    display: block; }

  .navbar-collapse {
    border-top: 1px solid transparent;
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.1); }

  .navbar-collapse.collapse {
    display: none !important;
    height: 0px;
    overflow: hidden; }

  .navbar-collapse.collapse.in {
    overflow-y: auto !important;
    display: block !important;
    overflow-x: visible !important;
    overflow-y: hidden !important; }

  .navbar-nav {
    float: left; }

  .navbar-nav > li {
    float: none; }

  .navbar-nav > li > a {
    padding-top: 10px;
    padding-bottom: 10px;
    line-height: 12px !important; }

  #nav_desktop, .container, .navbar-default .navbar-collapse {
    height: auto !important; }

  .container {
    padding-bottom: 20px; }

  .navbar-logo {
    overflow: visible; }

  .navbar-right {
    float: left !important; }

  #top_nav_bar .search_button {
    float: left;
    top: 5px;
    left: 10px;
    margin-right: 20px; }
  .begin_quote_btn {
    margin-top: 0;
    width: auto;
    height: auto;
    overflow: x; }

  .user_welcome {
    display: block; } }
/* 850
==================================================== */
/* 800
==================================================== */
@media all and (max-width: 800px) {
  .tabbed_menu li {
    padding: 15px;
    font-size: 0.875em; }
  .tabbed_menu li.active_tab:after {
    top: 44px;
    left: 64px !important; } }
/* 768 (Mobile Break)
==================================================== */
@media all and (max-width: 768px) {
  table {
    font-size: 0.625em; }

  .manage_user_name {
    width: 25%; }

  .manage_user_email {
    width: 35%; } }
/* 740
==================================================== */
@media all and (max-width: 740px) {
  .tabbed_menu li {
    padding: 15px 20px;
    float: none; }

  li.active_tab {
    -webkit-border-radius: 4px;
    border-radius: 4px; }
    li.active_tab:after {
      display: none; } }
/* 640
==================================================== */
/* 600
==================================================== */
/* 500
==================================================== */
/* 400
==================================================== */
/* 360
==================================================== */