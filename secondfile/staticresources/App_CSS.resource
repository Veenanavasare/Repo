@charset "UTF-8";

/*=================================================================
AT&T Partner Exchange Master Stylesheet ---------------------------
===================================================================



/*! normalize.css v3.0.0 | MIT License | git.io/normalize */
html {
    font-family: sans-serif;
    -ms-text-size-adjust: 100%;
    -webkit-text-size-adjust: 100%;
}
/**
 * Remove default margin.
 */
body {
    margin: 0;
}
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
    display: block;
}
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
    /* 2 */
}
/**
 * Prevent modern browsers from displaying `audio` without controls.
 * Remove excess height in iOS 5 devices.
 */
audio:not([controls]) {
    display: none;
    height: 0;
}
/**
 * Address `[hidden]` styling not present in IE 8/9.
 * Hide the `template` element in IE, Safari, and Firefox < 22.
 */
[hidden],
template {
    display: none;
}
/* Links
   ========================================================================== */
/**
 * Remove the gray background color from active links in IE 10.
 */
a {
    background: transparent;
}
/**
 * Improve readability when focused and also mouse hovered in all browsers.
 */
a:active,
a:hover {
    outline: 0;
}
/* Text-level semantics
   ========================================================================== */
/**
 * Address styling not present in IE 8/9, Safari 5, and Chrome.
 */
abbr[title] {
    border-bottom: 1px dotted;
}
/**
 * Address style set to `bolder` in Firefox 4+, Safari 5, and Chrome.
 */
b,
strong {
    font-weight: bold;
}
/**
 * Address styling not present in Safari 5 and Chrome.
 */
dfn {
    font-style: italic;
}
/**
 * Address variable `h1` font-size and margin within `section` and `article`
 * contexts in Firefox 4+, Safari 5, and Chrome.
 */
h1 {
    font-size: 2em;
    margin: 0.67em 0;
}
/**
 * Address styling not present in IE 8/9.
 */
mark {
    background: #ff0;
    color: #000;
}
/**
 * Address inconsistent and variable font size in all browsers.
 */
small {
    font-size: 80%;
}
/**
 * Prevent `sub` and `sup` affecting `line-height` in all browsers.
 */
sub,
sup {
    font-size: 75%;
    line-height: 0;
    position: relative;
    vertical-align: baseline;
}
sup {
    top: -0.5em;
}
sub {
    bottom: -0.25em;
}
/* Embedded content
   ========================================================================== */
/**
 * Remove border when inside `a` element in IE 8/9.
 */
img {
    border: 0;
}
/**
 * Correct overflow displayed oddly in IE 9.
 */
svg:not(:root) {
    overflow: hidden;
}
/* Grouping content
   ========================================================================== */
/**
 * Address margin not present in IE 8/9 and Safari 5.
 */
figure {
    margin: 1em 40px;
}
/**
 * Address differences between Firefox and other browsers.
 */
hr {
    -moz-box-sizing: content-box;
    box-sizing: content-box;
    height: 0;
}
/**
 * Contain overflow in all browsers.
 */
pre {
    overflow: auto;
}
/**
 * Address odd `em`-unit font size rendering in all browsers.
 */
code,
kbd,
pre,
samp {
    font-family: monospace, monospace;
    font-size: 1em;
}
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
    /* 3 */
}
/**
 * Address `overflow` set to `hidden` in IE 8/9/10.
 */
button {
    overflow: visible;
}
/**
 * Address inconsistent `text-transform` inheritance for `button` and `select`.
 * All other form control elements do not inherit `text-transform` values.
 * Correct `button` style inheritance in Firefox, IE 8+, and Opera
 * Correct `select` style inheritance in Firefox.
 */
button,
select {
    text-transform: none;
}
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
    /* 3 */
}
/**
 * Re-set default cursor for disabled elements.
 */
button[disabled],
html input[disabled] {
    cursor: default;
}
/**
 * Remove inner padding and border in Firefox 4+.
 */
button::-moz-focus-inner,
input::-moz-focus-inner {
    border: 0;
    padding: 0;
}
/**
 * Address Firefox 4+ setting `line-height` on `input` using `!important` in
 * the UA stylesheet.
 */
input {
    line-height: normal;
}
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
    /* 2 */
}
/**
 * Fix the cursor style for Chrome's increment/decrement buttons. For certain
 * `font-size` values of the `input`, it causes the cursor style of the
 * decrement button to change from `default` to `text`.
 */
input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
    height: auto;
}
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
    box-sizing: content-box;
}
/**
 * Remove inner padding and search cancel button in Safari and Chrome on OS X.
 * Safari (but not Chrome) clips the cancel button when the search input has
 * padding (and `textfield` appearance).
 */
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-decoration {
    -webkit-appearance: none;
}
/**
 * Define consistent border, margin, and padding.
 */
fieldset {
    border: 1px solid #c0c0c0;
    margin: 0 2px;
    padding: 0.35em 0.625em 0.75em;
}
/**
 * 1. Correct `color` not being inherited in IE 8/9.
 * 2. Remove padding so people aren't caught out if they zero out fieldsets.
 */
legend {
    border: 0;
    /* 1 */
    padding: 0;
    /* 2 */
}
/**
 * Remove default vertical scrollbar in IE 8/9.
 */
textarea {
    overflow: auto;
}
/**
 * Don't inherit the `font-weight` (applied by a rule above).
 * NOTE: the default cannot safely be changed in Chrome and Safari on OS X.
 */
optgroup {
    font-weight: bold;
}
/* Tables
   ========================================================================== */
/**
 * Remove most spacing between table cells.
 */
table {
    border-collapse: collapse;
    border-spacing: 0;
}
td,
th {
    padding: 0;
}

/* http://meyerweb.com/eric/tools/css/reset/ 
   v2.0 | 20110126
   License: none (public domain)
*/
html,
body,
div,
span,
applet,
object,
iframe,
h1,
h2,
h3,
h4,
h5,
h6,
p,
blockquote,
pre,
a,
abbr,
acronym,
address,
big,
cite,
code,
del,
dfn,
em,
img,
ins,
kbd,
q,
s,
samp,
small,
strike,
strong,
sub,
sup,
tt,
var,
b,
u,
center,
dl,
dt,
dd,
ol,
ul,
li,
i,
fieldset,
form,
label,
legend,
table,
caption,
tbody,
tfoot,
thead,
tr,
th,
td,
article,
aside,
canvas,
details,
embed,
figure,
figcaption,
footer,
header,
hgroup,
menu,
nav,
output,
ruby,
section,
summary,
time,
mark,
audio,
video {
   /* margin: 0; */
    padding: 0;
    border: 0;
    font-size: 100%;
    /*font: inherit; */
    vertical-align: baseline;
    
}

/* HTML5 display-role reset for older browsers */
article,
aside,
details,
figcaption,
figure,
footer,
header,
hgroup,
menu,
nav,
section {
    display: block;
}
body {
    line-height: 1;
}
ol,ul {
    list-style: none;
}
blockquote,
q {
    quotes: none;
}
blockquote:before,
blockquote:after,
q:before,
q:after {
    content: '';
    content: none;
}
table {
    border-collapse: collapse;
    border-spacing: 0;
}

/* Generated by Font Squirrel (http://www.fontsquirrel.com) on August 22, 2014 */
@font-face{font-family:'omnes_light';src:url("PortalDesignFonts/omnes_light.eot");src:url("PortalDesignFonts/omnes_light.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/omnes_light.woff2") format("woff2"),
url("PortalDesignFonts/omnes_light.woff") format("woff"),
url("PortalDesignFonts/omnes_light.ttf") format("truetype"),
url("PortalDesignFonts/omnes_light.svg#omnes_light") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'omnes_att_iilight_italic';src:url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.eot");src:url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.ttf") format("truetype"),
url("PortalDesignFonts/omnes_att_ii_light-italic-webfont.svg#omnes_att_iilight") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'omnes_att_iimedium';src:url("PortalDesignFonts/omnes_att_ii_medium-webfont.eot");src:url("PortalDesignFonts/omnes_att_ii_medium-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/omnes_att_ii_medium-webfont.ttf") format("truetype"),
url("PortalDesignFonts/omnes_att_ii_medium-webfont.svg#omnes_att_iilight") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'omnes_att_iimedium_italic';src:url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.eot");src:url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.woff2") format("woff2"),
url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.woff") format("woff"),
url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.ttf") format("truetype"),
url("PortalDesignFonts/omnes_att_ii_medium-italic-webfont.svg#omnes_att_iilight") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'omnesatt_iiregular';src:url("PortalDesignFonts/omnes_att_ii-regular-webfont.eot");src:url("PortalDesignFonts/omnes_att_ii-regular-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/omnes_att_ii-regular-webfont.ttf") format("truetype"),
url("PortalDesignFonts/omnes_att_ii-regular-webfont.svg#omnes_att_iilight") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'clearviewattlight';src:url("PortalDesignFonts/clvatt-light-webfont.eot");src:url("PortalDesignFonts/clvatt-light-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/clvatt-light-webfont.woff2") format("woff2"),
url("PortalDesignFonts/clvatt-light-webfont.woff") format("woff"),
url("PortalDesignFonts/clvatt-light-webfont.ttf") format("truetype"),
url("PortalDesignFonts/clvatt-light-webfont.svg#clearviewattlight") format("svg");
font-weight:normal;
font-style:normal;
}
@font-face{font-family:'clearviewattregular';src:url("PortalDesignFonts/clvatt-book-webfont.eot");src:url("PortalDesignFonts/clvatt-book-webfont.eot?#iefix") format("embedded-opentype"),
url("PortalDesignFonts/clvatt-book-webfont.woff") format("woff"),
url("PortalDesignFonts/clvatt-book-webfont.ttf") format("truetype"),
url("PortalDesignFonts/clvatt-book-webfont.svg#omnes_att_iilight") format("svg");
font-weight:normal;
font-style:normal;
}

/* APP ANIMATIONS
====================================================
==================================================== */
/* Robyn 7/28/15: Not sure if these styles are used in the force portal or were only on kavTest */
.reveal-animation.ng-hide.ng-hide-add-active {
  display: block !important; }

.reveal-animation.ng-hide-remove {
  -webkit-animation: enter_sequence .5s linear;
  /* Safari/Chrome */
  animation: enter_sequence .5s linear;
  /* IE10+ and Future Browsers */ }

.reveal-animation.ng-hide-add {
  -webkit-animation: leave_sequence .5s linear;
  /* Safari/Chrome */
  animation: leave_sequence .5s linear;
  /* IE10+ and Future Browsers */ }

@-webkit-keyframes enter_sequence {
  0% {
    opacity: 0; }
  100% {
    opacity: 1; } }
@keyframes enter_sequence {
  0% {
    opacity: 0; }
  100% {
    opacity: 1; } }
@-webkit-keyframes leave_sequence {
  0% {
    opacity: 1; }
  100% {
    opacity: 0; } }
@keyframes leave_sequence {
  0% {
    opacity: 1; }
  100% {
    opacity: 0; } }
@-webkit-keyframes fadein-added-customer {
  0% {
    opacity: 0;
    background: #61d90f; }
  100% {
    opacity: 1;
    background: #fff; } }
@-moz-keyframes fadein-added-customer {
  0% {
    opacity: 0;
    background: #61d90f; }
  100% {
    opacity: 1;
    background: #fff; } }
@-o-keyframes fadein-added-customer {
  0% {
    opacity: 0;
    background: #61d90f; }
  100% {
    opacity: 1;
    background: #fff; } }
@keyframes fadein-added-customer {
  0% {
    opacity: 0;
    background: #61d90f; }
  100% {
    opacity: 1;
    background: #fff; } }
.fadein_added_customer td {
  -webkit-animation: fadein-added-customer 2s;
  /* Safari 4+ */
  -moz-animation: fadein-added-customer 2s;
  /* Fx 5+ */
  -o-animation: fadein-added-customer 2s;
  /* Opera 12+ */
  animation: fadein-added-customer 2s;
  /* IE 10+, Fx 29+ */ }

/* START OF ATT FOUNDRY STYLES | DEFAULTS
====================================================
==================================================== */
.container {
    padding:0 10px;
    width:100%;
}
.navbar-nav.navbar-right:last-child {
    margin-right:10px;
}
.navbar-default,
.navbar-default .navbar-collapse,
.navbar-default .navbar-form {
    border-color:#FFF;
    background:#FFF;
}
.navbar-brand {
    margin-left:0 !important;
}
.navbar-toggle {
    margin-top:15px;
}

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
html,
body {
    width:100%;
    height:100%;
}
body {
    font-family:omnesatt_iiregular;
    font-size:1em;
    /* robyn 1/21/16: updated property so page would scroll horizontally as needed */
    overflow-x:visible !important;
    background:#f7f7f7;
}
h1 {
    font-family:omnes_light;
    font-size:2.625em;
    /*color:#666; */
}
button {
    margin:0 10px;
    padding:10px 20px;
    font-family:clearviewattregular;
    color:#fff;
    background:#056fab;
    border:0;
    -webkit-border-radius:4px;
    border-radius:4px;
}
button:hover {
    background:#3bc1f4;
}
button.secondary {
    color:#056fab;
    background:#fff;
    border:1px solid #e5e5e5;
}
button.secondary:hover {
    background:#e5e5e5;
}
/*li {
    list-style:none;
} */
a {
  color:#3bc1f4; 
  /*color: #0568ae;*/ /* Robyn 4/10/16: this is correct link color but must assess impact before making update */
  outline: 0 !important;
  text-decoration: none !important;
}
a:hover {
    text-decoration:none !important;
}
.btn-link {
  color: #0568ae; /* Robyn 4/10/16: update color on mktg page side bar navigation to match styleguide v9 */
}
.btn-link:hover, 
.btn-link:focus, 
.btn-link:active {
  color: #71c5e8; /* Robyn 4/10/16: update color on mktg page side bar navigation to match styleguide v9 */
}
.btn:hover {
    text-decoration:none;
}
.slice {
    padding:60px 0;
}
.width_100 {
    float:left;
    margin:10px 0;
    width:100%;
}
.hero_message {
    margin-top:100px;
    padding:20px;
    width:65%;
    background-color:rgba(255, 255, 255, 0.7);
}
.hero_message h1 {
    margin-bottom:10px;
    position:relative;
    top:20%;
    font-family:omnes_att_iilight_italic;
    font-size:2.75em;
}
.hero_message h2 {
    font-size:1.125em;
    color:#666;
}
.gray_bg {
    background:#f7f7f7;
}
.blue_button {
    padding:10px 40px;
    color:#fff;
    border:0;
    background:#056fab;
    -webkit-border-radius:4px;
    border-radius:4px;
}
.blue_button:hover {
    color:#fff;
    background:#068fdd;
}
.overlay {
    display:none;
    position:fixed;
    top:0;
    left:0;
    width:100%;
    height:100%;
    background:black;
    opacity:.85;
    z-index:10000;
    cursor:pointer;
}
.dashed_hr {
    margin:40px 0;
    border-bottom:1px dashed #ccc;
}
.blue_hr {
    border-bottom:1px solid #056fab;
}
.sectionHr {
    width: 100%;
    margin: 0;
    border-bottom: 1px solid #d3d3d3;
}
.orange_strong {
    font-family:omnes_att_iimedium;
    color:#ef6f00;
}
.has_bullets li {
    margin-left:20px;
    margin-bottom: 10px;
    line-height: 1.2em !important;
    list-style:disc !important;
}
strong {
    font-family:omnes_att_iimedium;
}
sup,
sub {
    font-size:75%;
    line-height:0;
    vertical-align:baseline;
}
sup {
    top:-0.5em;
    left:0.15em !important; 
}
sub {
    bottom:-0.25em
}
input.input_error {
    border:1px solid #d23939 !important;
    background:#fef3f1
}
label.input_error,
p.input_error {
    color:#d23939
}
p.input_error {
    font-size:0.75em
}
.font12 {
    font-size:0.75em
}
p.fine-print { 
    font-size: 0.8em;
    font-family: 'omnes_att_iilight_italic';
    margin: 10px 0px;
}
.dataTable {
    width:auto
}
::-webkit-scrollbar {
    width:12px
}
/* Track */
::-webkit-scrollbar-track {
    background:#ebebeb
}
/* Handle */
::-webkit-scrollbar-thumb {
    background:#056fab
}
::-webkit-scrollbar-thumb:window-inactive {
    background:rgba(5, 111, 171, 0.4)
}
.tableHeaderRow td {
    cursor:pointer
}

/* INPUTS & SELECTS
====================================================
==================================================== */
input {
    float:left;
    padding:0 10px;
    width:100%;
    height:32px;
    border:1px solid #ccc;
    -webkit-border-radius:4px;
    border-radius:4px
}
input[type=checkbox].css-checkbox {
    position:absolute;
    overflow:hidden;
    margin:-1px;
    padding:0;
    padding-left:27px;
    z-index:-1000;
    clip:rect(0 0 0 0);
    height:1px;
    width:1px;
    border:0
}
input[type=checkbox].css-checkbox+label.css-label,
input[type=checkbox].css-checkbox+label.css-label.clr {
    padding-left:27px;
    height:17px;
    display:inline-block;
    line-height:17px;
    background-repeat:no-repeat;
    background-position:0 0;
    vertical-align:middle;
    cursor:pointer
}
input[type=checkbox].css-checkbox:checked+label.css-label,
input[type=checkbox].css-checkbox+label.css-label.chk {
    background-position:0 -17px
}
label.css-label {
    background-image: url(portalDesignImg/csscheckbox.png);
    /*background-image:url("{!URLFOR($Resource.portalDesignImg, 'csscheckbox.png')}") no-repeat;*/
    -webkit-touch-callout:none;
    -webkit-user-select:none;
    -khtml-user-select:none;
    -moz-user-select:none;
    -ms-user-select:none;
    user-select:none
}
table a {
    color:#3bc1f4
}
.styled-select select,
.styled-select-small select {
    background:transparent;
    width:100%;
    padding:5px;
    line-height:16px;
    border:0;
    border-radius:0;
    height:27px;
    -webkit-appearance:none;
	-moz-appearance: none;
    cursor:pointer
}
.styled-select,
.styled-select-small {
    width:auto;
    overflow:hidden;
    border:1px solid #ccc;
    cursor:pointer;
    -webkit-border-radius:4px;
    border-radius:4px
}
.styled-select {
    height:32px;
    font-size:1em;
    background: url(portalDesignImg/new_arrow.png) no-repeat right #fff;
}
.styled-select-small {
    height:26px;
    background: url(portalDesignImg/new_arrow_small.png) no-repeat right #fff;
}
.adjust-select {
    position:relative;
    top:-11px
}
.adjust-select-small {
    width:160px
}
.css-check-label {
    margin-top:20px;
    font-size:0.875em !important
}

/*
    Tabbed Menu: Begin Quote, Training
*/
.tabbed_menu {
    position:relative;
    margin-top:40px;
    z-index:1000
}
.tabbed_menu li {
    float:left;
    padding:20px 50px;
    background:#fff;
    cursor:pointer
}
.tabbed_menu li:hover {
    color:#3bc1f4
}
/* Developers Note Robyn 12/30/15: does not look like li.active_tab is being used, and .tabbed_menu li:last-child style was applying a 
border to only one corner of the tabbed menu */
/*.tabbed_menu li.active_tab:first-child {
    -webkit-border-top-left-radius:4px;
    -moz-border-radius-topleft:4px;
    border-top-left-radius:4px
}
.tabbed_menu li.active_tab {
    color:#fff;
    background:#056fab;
    -webkit-transition:background 0.2s ease-in-out;
    -ms-transition:background 0.2s ease-in-out;
    -o-transition:background 0.2s ease-in-out;
    transition:background 0.2s ease-in-out
}
.tabbed_menu li.active_tab:hover {
    background:#068fdd
}
.tabbed_menu li.active_tab:after {
    position:absolute;
    top:56px;
    left:105px;
    content:"";
    width:0;
    height:0;
    border-style:solid;
    border-width:10px 20.5px 0 20.5px;
    border-color:#056fab transparent transparent transparent
}
.tabbed_menu li:last-child {
    -webkit-border-top-right-radius:4px;
    -moz-border-radius-topright:4px;
    border-top-right-radius:4px
}*/


/* TABLES
====================================================
==================================================== */
.table_container {
    margin:0 auto;
    max-width:1168px;
    border:1px solid #ccc;
    -webkit-border-radius:5px;
    border-radius:5px
}
.table_container table {
    width:100%;
    font-size:1em
}
.table_container thead td {
    padding:5px 2px 0 10px;
    border-bottom:1px dashed #ccc;
    background:#fff
}
.table_container thead a {
    cursor:pointer
}
.table_container thead label {
    width:100%
}
.table_container tbody tr {
    height:26px;
    line-height:24px;
    border-bottom:1px dotted #CCC
}
.table_container tbody tr:nth-child(even) {
    background:#f9f9f9
}
.table_container td {
    padding-top:5px;
    padding-left:10px;
    border-right:1px solid #ebebeb
}
.table_container input {
    padding:0 10px
}
.table_container .css-checkbox {
    margin:0 10px;
    padding:0 10px
}

/*  ICONS
====================================================
==================================================== */
.blue_globe,
.blue_cloud,
.blue_wifi,
.blue_support,
.blue_doc,
.blue_core {
    float:left;
    margin-right:20px;
    width:60px;
    height:60px;
    background-size:1350px 1350px !important
}
.blue_globe {
    background-position:-120px -60px
}
.blue_cloud {
    background-position:-240px -40px
}
.blue_wifi {
    background-position:-180px -60px
}
.blue_support {
    background-position:-356px -60px
}
.blue_doc {
    background-position:-416px -60px
}
.blue_core {
    background-position:-479px -60px
}
.excel_icon {
    float:left;
    width:15px;
    height:14px;
    background-image: url(portalDesignImg/excel.gif), none;
}
.pdf_icon {
    float:left;
    width:21px;
    height:26px;
    background-position:-200px -80px
}

/* SEARCH
====================================================
==================================================== */
.app_search_area {
    display:none;
    position:absolute;
    top:15%;
    left:0;
    right:0;
    margin-left:auto;
    margin-right:auto;
    padding:30px 0px 30px 40px;
    width:420px;
    height:auto;
    background:white;
    z-index:10001
}
.app_search_area button {
    position:relative;
    z-index:3;
    margin-left:-10px;
    -webkit-border-top-right-radius:4px !important;
    -webkit-border-bottom-right-radius:4px !important;
    -moz-border-radius-topright:4px !important;
    -moz-border-radius-bottomright:4px !important;
    border-top-right-radius:4px !important;
    border-bottom-right-radius:4px !important
}
#the_app_search_input {
    position:relative;
    z-index:2;
    top:0px;
    padding:7px;
    width:250px;
    height:36px;
    border:1px solid #ccc;
    -webkit-border-top-left-radius:4px;
    -webkit-border-bottom-left-radius:4px;
    -moz-border-radius-topleft:4px;
    -moz-border-radius-bottomleft:4px;
    border-top-left-radius:4px;
    border-bottom-left-radius:4px
}
.close_x {
    position:absolute !important;
    top:-37px;
    left:393px;
    width:27px;
    height:27px;
    background-position:-40px -120px;
    cursor:pointer
}

/* LAYOUTS
====================================================
==================================================== */
#top_nav_bar .search_button {
    float:none;
    top:13px;
    left:10px
}
#nav_desktop {
    margin-top:10px
}
#nav_desktop li {
    margin-right:-5px
}
.att_partner_exchange_logo {
    width:242px;
    height:34px
}
.begin_quote_btn {
    position:relative;
    left:10px;
    margin-top:-10px;
    padding:1px 12px 0px 12px;
    font-family:clearviewattlight;
    font-size:0.875em;
    line-height:40px;
    color:#fff;
    border:0;
    background:#056fab;
    -webkit-transition:background 0.2s ease-in-out;
    -ms-transition:background 0.2s ease-in-out;
    -o-transition:background 0.2s ease-in-out;
    transition:background 0.2s ease-in-out;
    -webkit-border-radius:3px;
    border-radius:3px
}
.begin_quote_btn:after {
    content:"";
    display:table;
    clear:both
}
.begin_quote_btn:hover {
    background:#3bc1f4
}
.navbar-header {
    margin-top:5px
}
.begin_quote_icon {
    float:left;
    width:30px;
    height:34px;
    background-position:-10px -80px
}
.notification_badge {
    position:absolute;
    top:-2px;
    left:10px;
    font-size:0.6875em;
    text-align:center;
    line-height:16px;
    color:#fff;
    background:#ef6f00;
    border-radius:50%;
    width:16px;
    height:16px
}
.user_badge {
    margin-top:6px
}
.user_badge:hover .notification_badge {
    background:#ff8923;
    -webkit-transition:background 0.2s ease-in-out;
    -ms-transition:background 0.2s ease-in-out;
    -o-transition:background 0.2s ease-in-out;
    transition:background 0.2s ease-in-out
}
.avatar,
.user_welcome {
    float:left
}
.user_welcome {
    margin-left:10px;
    font-size:0.75em;
    line-height:1.25em
}
.unactive_top:hover {
    color:#3bc1f4 !important
}
.active_top {
    position:relative;
    top:1px;
    height:62px;
    color:#fff !important;
    background:#056fab !important
}
.active_top:hover {
    color:#fff !important;
    background:#056fab !important
}
.nav_search_li,
.nav_quote_li {
    position:relative
}
.nav_search_li {
    z-index:3
}
.nav_search_li {
    z-index:2
}
.sub_navigation {
    margin-top:70px;
    font-family:"omnesatt_iiregular";
    color:#fff;
    display:block;
    height:0px;
    width:100%;
    background:#056fab;
    overflow:hidden
}
.sub_content {
    margin:0 auto;
    padding:40px 40px 20px 40px
}
.grow-content,
.products-content,
.manage-content,
.connect-content,
.developers-content,
.community-content {
    height:auto;
    display:none
}
.sub_links_container {
    margin:0 auto;
    padding:0;
    max-width:80%
}
.link-section {
    float:left;
    margin-bottom:30px
}
.link-section:after {
    content:"";
    display:table;
    clear:both
}
.link-section h4 {
    font-family:omnes_att_iilight_italic;
    font-size:1.5em;
    color:#b9ddf9;
    margin-bottom:5px;
    margin-top:0px
}
.link-section ul {
    margin-top:20px
}
.link-section li {
    margin-bottom:10px;
    display:block
}
.link-section li a {
    color:#fff
}
.link-section:last-child {
    margin-right:0
}

/* HEROES
====================================================
==================================================== */
#slice_hero {
    /* Robyn 6/14/16: hero style updates */
    height: 230px;
    background-size:cover;
    background-position:right top !important;
    margin-top: 0 !important;
}
#hero_banner {
    margin:0;
    padding:0;
    width:100%;
    background-repeat:no-repeat;
    background-position:center;
    background-size:cover
}
.hero_training {
    height:300px
}
.hero_manage {
    height:99px;
    background-image: url(portalDesignImg/heros/products.jpg) !important;
}

/* DASHBOARD
====================================================
==================================================== */
.welcome_div {
    margin:0 auto;
    padding:40px 40px 0 40px;
    max-width:1168px
}
#dashboard_container .manage_user_search_row {
    margin-top:0
}
.dashboard_options {
    margin:0 auto;
    padding:0px 40px 0 40px;
    max-width:1168px
}
.dashboard_options .status_more_options {
    position:relative;
    top:0px;
    right:0px;
    padding:10px 20px
}
.dashboard_options .status_more_options li {
    margin-bottom:10px
}
.customize_desktop {
    width:238px
}
.customize_desktop p {
    margin:5px 0 0 10px
}
.dash_widget {
    margin-bottom:0 !important
}
.manage_my_mobile_row li {
    margin:10px 0
}
.latest_news_widget {
    padding:20px;
    background:#fff;
    border:1px solid #e5e5e5
}
.latest_news_widget h4 {
    margin-bottom:10px
}
.latest_news_widget span {
    float:right
}
.latest_news_widget section {
    margin-bottom:20px;
    padding:20px;
    border-bottom:1px dashed #e5e5e5
}
.latest_news_widget section p {
    margin-bottom:20px
}
.latest_news_widget section em {
    font-size:0.75em;
    color:#ccc
}
.view_all_news {
    float:right;
    margin-top:10px
}
#table_manage_quotes_orders_length,
#table_manage_quotes_orders_filter,
#table_manage_quotes_orders_info,
#table_manage_quotes_orders_paginate,
#table_manage_customers_length,
#table_manage_customers_filter,
#table_manage_customers_info,
#table_manage_customers_paginate {
    display:none
}

/* App - Training
====================================================
==================================================== */
.hero_training .hero_message {
    position:absolute;
    left:10%;
    width:635px
}
.hero_training .hero_message button {
    position:absolute;
    top:130px;
    left:-10px
}
.hero_training .carousel {
    height:300px !important;
    margin-bottom:0
}
.hero_training .carousel .item {
    height:300px !important;
    background-color:#fff !important
}
.hero_training .carousel-indicators {
    bottom:20px
}
.hero_training .carousel-indicators .active {
    width:15px;
    height:15px;
    margin:4px;
    background-color:#056fab !important;
    border:1px solid #056fab
}
.hero_training .carousel-indicators li {
    display:inline-block;
    width:13px;
    height:13px;
    margin:5px;
    text-indent:-999px;
    cursor:pointer;
    background-color:#ccc !important;
    border:1px solid #8d8c8c;
    border-radius:10px
}
.couple_banner,
.green_lady,
.lawyer {
    height:387px
}
.couple_banner {
  background-image: url("portalDesignImg/heros/training/1s.jpg"); }
.green_lady {
  background-image: url("portalDesignImg/heros/training/2s.jpg"); }
.lawyer {
  background-image: url("portalDesignImg/heros/training/3s.jpg"); }
.course_modal {
    display:none;
    position:fixed;
    top:0;
    right:0;
    bottom:0;
    left:0;
    margin:60px auto;
    width:80%;
    height:auto !important;
    min-width:600px;
    line-height:1.5em;
    -webkit-border-radius:4px;
    border-radius:4px;
    z-index:10001
}
.course_header,
.course_modal_content,
.course_modal_footer {
    padding:20px
}
.course_header {
    border:1px solid #fff;
    background:#056fab;
    -webkit-border-top-left-radius:4px;
    -webkit-border-top-right-radius:4px;
    -moz-border-radius-topleft:4px;
    -moz-border-radius-topright:4px;
    border-top-left-radius:4px;
    border-top-right-radius:4px
}
.course_header h1 {
    font-size:2em;
    color:#fff
}
.course_modal_x_container {
    position:absolute;
    top:-10px;
    right:-10px;
    float:right;
    border-radius:50%;
    width:40px;
    height:40px;
    background:#fff;
    cursor:pointer
}
.course_modal_x {
    width:40px;
    height:40px;
    background-position:-186px -124px;
    background-size:1400px 1400px !important
}
.course_modal_content {
    background:#fff
}
.course_modal_content .blue_globe {
    width:88px;
    height:96px;
    background-size:1998px 1998px !important;
    background-position:-178px -81px
}
.course_modal_content .content_meat {
    margin-left:20px
}
.course_objectives_ul {
    margin:20px 0
}
.course_objectives_ul li {
    margin-left:20px;
    list-style-type:disc
}
.course_objectives_ul li:first-child,
.course_objectives_ul li:last-child {
    margin-left:0;
    list-style:none
}
.course_modal_footer {
    border-top:1px solid #056fab;
    background:#fff;
    -webkit-border-bottom-right-radius:4px;
    -webkit-border-bottom-left-radius:4px;
    -moz-border-radius-bottomright:4px;
    -moz-border-radius-bottomleft:4px;
    border-bottom-right-radius:4px;
    border-bottom-left-radius:4px
}
.course_modal_footer ul {
    float:right
}
.course_modal_footer li {
    float:left
}
.course_modal_footer:after {
    content:"";
    display:table;
    clear:both
}
.training_tabs_container {
    margin:0 auto 60px;
    background:#056fab
}
.training_tabs {
    margin:0 auto;
    padding:10px 20px;
    max-width:1168px;
    height:40px;
    color:#fff;
    background:#056fab
}
.training_tabs li {
    float:left;
    margin-right:40px
}
.training_tabs a {
    color:#fff
}
.blue_arrow_down {
    position:absolute;
    top:14px;
    width:45px;
    height:12px;
    background-position:-40px -80px
}
.my_current_courses,
.available_courses,
.all_courses {
    margin:0 auto 60px auto;
    max-width:1168px
}
.my_current_courses h2,
.available_courses h2,
.all_courses h2 {
    font-family:omnesatt_iiregular;
    font-size:2.25em
}
.my_current_courses table,
.available_courses table,
.all_courses table {
    width:100%
}
.my_current_courses .tabbed_menu ul,
.available_courses .tabbed_menu ul,
.all_courses .tabbed_menu ul {
    height:58px;
    border-bottom:2px solid #056fab
}
.available_courses h3,
.available_courses p {
    font-size:1.125em;
    line-height:1.375em
}
.available_courses em {
    font-size:0.75em
}
.current_course_action {
    position:relative;
    top:30px
}
.current_course_action button {
    float:right
}
.current_courses_progress {
    float:right
}
.current_courses_td {
    padding:20px 20px 0px
}
.current_courses_td span {
    position:relative;
    top:5px
}
.course_status {
    float:right
}
.expand_all {
    float:left;
    margin-right:10px !important;
    width:28px;
    height:28px;
    background-position:-80px -92px
}
.hero_running {
    height:698px;
    background-image: url("portalDesignImg/heros/training/runnerss.jpg");
}
.blue_hero {
    padding:70px 40px;
    text-align:center;
    color:#fff;
    background:#056fab
}
.blue_hero h1 {
    margin-bottom:40px;
    font-family:omnes_att_iimedium;
    font-size:2.25em;
    color:#fff
}
.blue_hero p {
    margin:0 auto;
    width:80%;
    font-size:1.875em;
    line-height:1.25em
}
.blue_hero ul {
    margin:40px auto;
    width:600px
}
.blue_hero li {
    float:left;
    margin-right:40px
}
.blue_hero li:last-child {
    margin-right:0
}
.gray_module_bg {
    padding:60px 0;
    width:100%;
    background:#e5e5e5
}
.cert_program_copy {
    margin-top:25%
}
.big_white_wifi {
    top:25px;
    left:15px;
    width:167px;
    height:135px;
    background-position:0 -161px
}
.big_white_cloud {
    width:205px;
    height:160px;
    background-position:-200px -134px
}
.big_white_globe {
    top:22px;
    width:141px;
    height:141px;
    background-position:-440px -160px
}
.cert_program_module {
    margin:0 auto;
    max-width:1168px
}
.cert_program_module h3 {
    margin-bottom:10px;
    font-family:omnes_att_iimedium;
    font-size:1.875em
}
.all_courses_sidebar {
    font-size:1.125em;
    color:#666
}
.all_courses_sidebar h4 {
    margin-bottom:20px;
    font-size:1.25em;
    color:#333
}
.all_courses_sidebar hr {
    margin:20px 0;
    border-bottom:1px dashed #ccc
}
.all_courses_sidebar li {
    line-height:1.375em
}
.all_courses_content .copy {
    float:left;
    margin-left:20px;
    width:80%
}
.all_courses_content .copy h1,
.all_courses_content .copy p {
    font-size:1.125em;
}
.all_courses_content .copy h1 {
    font-family:clearviewattregular;
}
.all_courses_content .copy em {
    color:#ef6f00
}
.all_courses_content .copy span {
    font-size:0.75em
}
.all_courses_content .completed {
    float:left;
    width:10%;
    font-family:omnes_att_iimedium_italic;
    font-size:1.125em;
    text-align:center
}
.selected_filters_row {
    margin-bottom:20px;
    font-size:1.125em
}
.selected_filters_row span {
    float:left;
    margin-right:20px;
    line-height:2em
}
.selected_filters_row .tag_button {
    float:left;
    margin-right:20px;
    padding:8px 12px;
    border:1px solid #e5e5e5;
    background:#fff;
    -webkit-border-radius:4px;
    border-radius:4px
}
.selected_filters_row .tag_button p {
    float:left
}
.selected_filters_row .tag_button .ico_close {
    float:right;
    margin-left:10px;
    background-position:-120px -80px
}
.all_courses_search {
    float:right
}
.avaliable_courses {
    margin-top:20px
}
.avaliable_courses li {
    border-bottom:2px dashed #ccc
}
.avaliable_course {
    margin:20px 0
}
.avaliable_course:after {
    content:"";
    display:table;
    clear:both
}
.completed_icon {
    margin-bottom:5px !important;
    width:32px;
    height:32px;
    background-position:-160px -80px
}
.training_transcript_container thead td {
    padding-top:10px;
    padding-bottom:10px;
    font-size:1.125em
}
.td_view_cert a {
    float:left;
    margin-left:10px
}
.excel_row {
    float:right;
    position:relative;
    top:30px;
    width:170px
}
.excel_row a {
    float:left;
    margin-left:10px
}


/* PRODUCTS
====================================================
==================================================== */
#products_content {
    max-width: 1168px;
    margin: 60px auto;
}
#products_content section {
    margin-bottom: 40px;
}
#products_content h1 {
    margin-bottom: 10px;
    font-size: 2.625em;
}
#products_content p {
    margin: 10px auto;
    line-height: 1.25em;
}
#products_content ul {
    margin-left: 20px;
    list-style: disc;
    line-height: 1.25em;
}
#products_content .active {
    box-shadow: none;
}
.products_left_nav {
    width:153px;
    padding-top:10px
}
.products_left_nav button {
    width:100%;
    display:block;
    font-size:1.1em;
    text-align:left;
    color:#009add
}
.products_left_nav button.active {
    background-color:#009add;
    color:#fff
}
.sticky {
    position:fixed;
    left:40px;
    top:100px;
    z-index:10001;
    border-top:0;
}
.load-product-content .overview li {
    list-style:disc;
}
/* product mobile styles */
.mobile-content-menu {
    display:none;
}
.dropdown-label {
    padding-top:15px;
    padding-bottom:15px;
    width:95%;
    margin:auto;
    border-radius:10px;
    border:1px solid silver;
    text-align:center;
    background-color:#f0f0f0;
    font-weight:bold;
    font-size:130%;
    text-transform:capitalize;
    cursor:pointer;
}
.dropdown-label:hover {
    background-color:#e4e4e4;
}
.mobile-dropdown-menu {
    border:1px solid silver;
    border-radius:10px;
    overflow:hidden;
    padding:0px;
    margin:0px;
    width:95%;
    margin:auto;
    margin-top:10px;
    display:none;
}
.mobile-dropdown-menu li {
    list-style:none;
    text-align:center;
    padding-top:15px;
    padding-bottom:15px;
    border-bottom:1px solid silver
}
.mobile-dropdown-menu a {
    text-decoration:none
}
/* end product mobile styles */
.infographic { margin: 20px 0; } /* imgs used on product overview detail pages */


/*
PRODUCTS - TRAINING PAGE STYLE
===================================================
*/

/* products training page styles do not appear to be used */

/*.training .product-icon {
  width: 20%;
  float: left; 
}
.training section .title {
    font-size: 1.125em !important;
    margin-bottom: 16px !important;
    color: #009add; 
}
.training section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; 
}
.training section ul {
    text-indent: 31px;
    list-style: none;
}
.training section li {
    list-style: none;
    margin-bottom: 7px;
}
.training section ul li:before {
    content: "�";
    margin-right: 9px;
}
.training section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; 
}
.technical_h1 {
    margin-bottom:40px
}
*/
.training .details {
    width:80%;
    float:right
}
.training section {
    background-color:#fff;
    padding:40px;
    border:1px solid #e9e9e9;
    margin-bottom:20px
}
.training section:after {
    content:"";
    display:table;
    clear:both
}

/*
PRODUCTS - PRICING PAGE STYLE
===================================================
*/

/* products pricing page styles do not appear to be used */

/*.pricing .icon {
    width: 20%;
    float: left; 
}*/
/*.pricing .details {
    width: 80%;
    float: right; 
}*/
/*.pricing section {
    background-color: #fff;
    padding: 40px;
    border: 1px solid #e9e9e9; 
}*/
/*.pricing section:after {
    content: "";
    display: table;
    clear: both; 
}*/
/*.pricing section .title {
    font-family: "omnes_att_iimedium" !important;
    font-size: 1.125em !important;
    margin-bottom: 0px !important;
    color: #009add; 
}*/
/*.pricing section .list-title {
    font-family: "omnes_att_iimedium";
    margin-bottom: 8px; 
}*/
/*.pricing section ul {
    text-indent: 31px;
    list-style: none !important; 
}
.pricing section li {
    list-style: none !important;
    margin-bottom: 7px !important; 
}
.pricing section ul li:before {
    content: "�";
    margin-right: 9px; 
}
.pricing section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; 
}*/

/*
PRODUCTS - DOCUMENTATION PAGE STYLE
===================================================
*/

/* products documentation page styles do not appear to be used */

/*.documentation .row {
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
    content: "�";
    margin-right: 9px; }
  .documentation section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }*/

.pricing .details,
.technical .details {
    width:85%;
    float:right
}
.pricing section,
.technical section {
    background-color:#fff;
    margin-bottom:30px;
    padding:40px;
    border:1px solid #e9e9e9
}
.pricing section:after,
.technical section:after {
    content:"";
    display:table;
    clear:both
}

.training section .icon,
.file-download .icon {
    float:left;
    margin-right:20px;
    width:10%;
    display: block;
}
.file-download .details {
    width:75%;
    float:right;
}
section.file-download {
    background-color:#fff;
    border:1px solid #e9e9e9;
    margin-bottom:20px !important;
    margin-right:20px;
    padding:20px;
    width:100%;
}
section.file-download ul {
    list-style:none !important;
}
section.file-download li {
    list-style:none !important;
    margin-bottom:7px !important;
}

/*
PRODUCTS - RESOURCES PAGE STYLE
===================================================
*/

/* products resources page styles do not appear to be used */

/*.resources_title {
    margin-bottom:20px;
    font-family:"omnes_att_iimedium" !important;
    font-size:1.125em !important
}
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
    content: "�";
    margin-right: 9px; }
.resources section .duration {
    background-image: url("portalDesignImg/duration.png");
    background-position: left 1px;
    background-repeat: no-repeat;
    height: 18px;
    margin-top: 22px;
    padding-left: 26px; }*/

/* App - MANAGE
====================================================
==================================================== */
#manage_content,
.manage_content {
    margin:0 auto 60px;
    padding:40px 20px 0;
    max-width:1168px
}
#manage_content h1,
.manage_content h1 {
    margin-bottom:10px;
    font-size:2.625em
}
#manage_content h2,
.manage_content h2 {
    font-size:1.5em;
    color:#ef6f00
}
#manage_content h3,
.manage_content h3 {
    font-size:1.5em;
    margin-bottom:10px;
}
#manage_content label,
.manage_content label {
    margin:10px 0;
    font-family:omnes_att_iimedium
}
#manage_content .pagination,
.manage_content .pagination {
    float:right
}
#manage_content .pagination span,
.manage_content .pagination span {
    margin-right:15px
}
#manage_content .pagination button,
.manage_content .pagination button {
    padding:5px 10px;
    font-family:omnes_att_iimedium;
    line-height:1.125em;
    color:#056fab;
    background:#fff;
    border:1px solid #ccc
}
#manage_content .pagination .diabled,
.manage_content .pagination .diabled {
    color:#666
}
.m0{
    margin:0 !important;
}
.warningText{
    color:#ea7200;
    font-family:omnes_att_iimedium;
}

.boldText{
    font-weight: bold;
    color: #000;
}
/* Manage User
==================================================== */
.manage_user_search_row {
    margin-top:40px;
    width:100%
}
.search_user_container {
    float:left;
    width:290px
}
.search_user_container label {
    margin-bottom:5px
}
#search_input {
    height:40px !important
}
.search_button {
    float:right;
    top:-33px;
    right:6px;
    width:30px;
    height:25px;
    background:#fff;
    background-position:-205px -47px;
    -webkit-border-top-right-radius:4px;
    -webkit-border-bottom-right-radius:4px;
    -moz-border-radius-topright:4px;
    -moz-border-radius-bottomright:4px;
    border-top-right-radius:4px;
    border-bottom-right-radius:4px;
    cursor:pointer
}
.search_button:hover {
    opacity:.8
}
.create_users_button {
    float:right
}
.create_users_button a {
    color:#fff
}
#manage_users_table_length,
#manage_users_table_filter,
#manage_users_table_info,
#manage_users_table_paginate {
    display:none
}
.check_col {
    width:48px;
    height:35px
}
.check-label {
    margin-left:10px;
    margin-bottom:5px
}
.manage_user_name {
    width:30%
}
.manage_user_email {
    width:40%
}
.reorder_btn {
    position:relative;
    top:-15px;
    margin-right:10px !important;
    width:18px;
    height:18px;
    background-position:-40px -40px;
    cursor:pointer
}
.td_dropdown_arrow,
.td_down_arrow {
    position:relative;
    top:-10px;
    margin-right:10px !important;
    height:8px;
    cursor:pointer
}
.td_dropdown_arrow {
    width:16px;
    background-position:-64px -40px
}
.td_down_arrow {
    width:12px;
    background-position:-60px -50px
}
.status_more_options {
    position:absolute;
    top:45px;
    right:15px;
    padding:10px 20px 20px 20px;
    font-size:0.75em;
    border-left:1px solid #ccc;
    border-right:1px solid #ccc;
    border-bottom:1px solid #ccc;
    background:#fff
}
.status_more_options button {
    margin-top:10px
}
.btn_deactivate_user {
    margin-top:20px
}

/* Create User
==================================================== */
.basic_portal_access {
    margin:40px 0 25px
}
.basic_portal_access h3 {
    margin-bottom:10px
}
.basic_portal_access ul {
    margin:10px 0 10px 20px
}
.basic_portal_access li {
    list-style:disc;
    line-height:1.375em
}
.basic_portal_access p {
    margin-top:20px
}
.optional_permissions table {
    width:100%
}
.optional_permissions_table {
    width:100%;
    border:1px solid #ccc
}
.optional_permissions_table header {
    position:relative;
    top:10px
}
.optional_permissions_table td {
    padding:20px
}
.optional_permissions_table h3 {
    float:left;
    margin-top:5px
}
.optional_permissions_table h4 {
    font-size:1.25em;
    color:#056fab
}
.optional_permissions_table li {
    line-height:1.5em
}
.optional_permissions_table .td_sub_headers td {
    padding-bottom:0
}
.optional_permissions_table .td_body_options td {
    padding:10px 15px 20px
}
.optional_permissions_table .bullets {
    margin-left:28px;
    font-size:0.75em;
    color:#999
}
.optional_permissions_table .hr {
    width:100%;
    border-bottom:1px dashed #ccc
}
.btn_create_user {
    margin-top:20px
}
.td_hr {
    padding:0 !important;
    padding-top:10px !important
}
.optional_permissions_checkgroup {
    float:left;
    margin-left:10px
}
.optional_permission_options label {
    font-family:clearviewattregular;
    font-size:0.875em !important
}
.has_r_border {
    padding-right:30px;
    border-right:1px solid #e5e5e5
}

/* Add New Customer
==================================================== */
.add_new_customer_header {
    margin-bottom:40px
}
.dashed_hr {
    height:0px;
    border-bottom:1px dashed #ccc;
    background:transparent
}
.add_sites_tbody input {
    width:95% !important;
    height:24px !important
}
.added_sites_tbody {
    font-size:0.875em
}
.add_site_btn {
    position:relative;
    top:-8px;
    padding:4px 10px;
    width:100px;
    font-size:0.875em
}
.add_customer_complete_row {
    margin-top:40px
}
.add_customer_complete_row button,
.add_customer_complete_row p {
    float:left
}
.add_customer_complete_row p {
    margin-top:10px;
    margin-left:10px
}
.add_site_input_div {
    position:relative
}
.add_site_input_div .styled-select-small {
    float:left;
    width:60%;
    height:25px
}
.add_site_input_div .styled-select-small select {
    height:25px
}
.add_site_input_div .adjust-select-small {
    float:left;
    top:0 !important;
    width:100px
}
#add_site_loc2 {
    width:40% !important;
    margin-left:10px
}
.add_site_location_adjust {
    position:relative;
    top:2px
}
.add_sites_location {
    position:relative;
    top:5px
}
.add_sites_location p {
    float:left
}
.add_sites_location p:last-child {
    margin-left:10px
}
#add_site_location {
    float:left;
    padding-top:10px;
    margin-left:10px;
    width:40% !important
}
#tbody_added_sites_here {
    display:none
}

/* Manage Customers
==================================================== */
.added_customer_alert {
    display:none;
    margin:0 0 20px;
    color:#4ca90c
}

/* Business Profile
==================================================== */
.business_profile_header {
    margin-bottom:40px
}

/* Manage Quotes & Order
==================================================== */
.manage_quotes_order,
.manage_quotes_customer {
    width:15% !important
}
.manage_quotes_modified {
    width:12% !important
}
.manage_quotes_actions {
    width:17% !important
}
.manage_quotes_type,
.manage_quotes_status,
.manage_quotes_products {
    width:10% !important;
    background:#edf8fd !important
}
.manage_quotes_progress {
    text-align:center
}
.manage_quotes_progress ul {
    max-width:80px
}

/* App - CONTACT
====================================================
==================================================== */
#slice_contact_us {
    margin:0;
    padding:0 0 80px 0;
    width:100%;
    background:url(portalDesignImg/heros/contact.jpg) 0 0 no-repeat;
    background-size:cover !important
}
#slice_contact_us h1 {
    margin:30px 0 40px;
    font-family:omnes_att_iimedium;
    font-size:2.625em
}
#slice_contact_us h2 {
    font-family:omnesatt_iiregular;
    font-size:1.125em
}
#slice_contact_us label {
    margin:10px 0
}
#slice_contact_us .submit_contact {
    float:right;
    margin-left:0
}
.service_select {
    margin-top:10px;
    width:100%
}
.service_select select {
    margin-left:10px
}
.contact_directions {
    margin-bottom:20px
}
.max_1000_width {
    margin:0 auto;
    padding:0 40px;
    max-width:1000px
}
.contact_form_container {
    margin-top:40px;
    padding:40px;
    background:#fff
}
.contact_header {
    margin:60px 0;
    padding:0 40px;
    text-align:center
}

/* App - BEGIN QUOTE
====================================================
==================================================== */
.page_count {
    float:right;
    margin:30px 10px 0 0
}
.begin_quote_checks {
    width:40px !important;
    padding-right:15px !important
}
.blue_hr {
    height:2px;
    background:#056fab
}
.begin_quote_buttons {
    float:right
}

/* PROFILE
====================================================
==================================================== */
#profile_content {
    margin:0 auto 60px;
    padding:40px;
    max-width:1168px
}
#profile_content h1 {
    margin-bottom:10px;
    font-size:2.625em
}
#profile_content h3 {
    font-family:omnes_att_iimedium;
    font-size:1.25em
}
#profile_content input {
    margin-bottom:15px
}
#profile_content label {
    margin-bottom:10px
}
#profile_content button {
    margin-top:20px;
    padding:15px 40px
}
#profile_content .optional_permissions_table h3 {
    margin-top:-3px
}
.profile_header {
    margin-bottom:40px
}
.profile_photo {
    margin-bottom:20px
}
#current_avatar {
    width:200px;
    cursor:pointer
}
#choose_file {
    position:relative;
    top:-10px;
    left:30px;
    width:230px !important;
    border:none;
    z-index:1
}
.upload_photo {
    float:left;
    position:relative;
    margin-right:34px;
    width:24px;
    height:17px;
    background-position:-40px -63px;
    z-index:2;
    top:-50px
}
.upload_p {
    float:left;
    margin-left:10px;
    display:block;
    position:relative;
    top:-75px;
    left:20px;
    padding:10px 10px 10px 0;
    width:230px;
    color:#006497;
    background:#f7f7f7;
    cursor:pointer;
    z-index:2
}
.profile_row {
    margin-bottom:60px
}
.profile_table_form {
    margin-bottom:30px;
    width:290px
}
.question_icon {
    float:right;
    position:absolute;
    top:370px;
    right:21px;
    border-radius:50%;
    width:20px;
    height:20px;
    font-size:0.875em;
    line-height:1.25em;
    text-align:center;
    color:#056fab;
    background:#fff;
    border:1px solid #ccc;
    cursor:pointer
}
.notification_col {
    float:right;
    width:36.66%
}
.my_notifications {
    padding:20px;
    background:#fff;
    border:1px solid #ccc
}
.my_notifications hr {
    border-bottom:1px dashed #ccc
}
.my_notifications h4 {
    line-height:1.375em
}
.my_notifications ul {
    margin-top:40px
}
.my_notifications li {
    margin-bottom:10px
}
.my_notifications p {
    margin-left:46px;
    margin-bottom:20px
}
.optional_permissions,
.optional_permissions_mobile {
    background:#fff
}
.optional_permissions_mobile {
    display:none
}
.optional_permissions_mobile h3 {
    margin-bottom:20px
}
.optional_permissions_mobile .mobile_label {
    font-size:0.875em !important
}
.optional_permissions_mobile h4 {
    margin-bottom:10px
}

/* COMPLETE REGISTRATION
====================================================
==================================================== */
#complete_registration_form button {
    margin-top:40px
}
#complete_registration_form .question_icon {
    top:405px
}
.welcome_message {
    float:right;
    position:relative;
    width:70%;
    z-index:2
}
.blue_bullet {
    width:100%;
    min-height:40px
}
.blue_bullet h3 {
    float:left;
    font-family:omnes_att_iilight_italic !important;
    color:#056fab
}
.blue_circle {
    float:left;
    margin:0 10px 0 0;
    border-radius:50%;
    width:36px;
    height:36px;
    line-height:36px;
    text-align:center;
    color:#fff;
    background:#056fab
}
.left_wedge {
    float:left;
    position:relative;
    top:70px;
    left:51px;
    width:21px;
    height:40px;
    background-position:0 -120px;
    z-index:3
}

/* FOOTER STYLES
====================================================
==================================================== */
.footer_links_containers {
    padding:10px 40px;
    width:100%;
    background:#ededed
}
#footer_links,
#slice_footer {
    margin:60px auto;
    max-width:1168px
}
#footer_links {
    margin-bottom:40px
}
#footer_links li {
    margin:8px 0;
    font-size:0.75em
}
#footer_links li:first-child {
    font-size:1em;
    color:#999
}
#footer_links a {
    color:#3bc1f4
}
#footer_links a:hover {
    color:#056fab
}
#slice_footer {
    font-family:Arial,
    sans-serif;
    font-size:11px; /* Robyn 6/16/16: adjust font size */
    line-height:1.25em
}
.footer_logo_container {
    float:left;
    margin-right:12px; /* Robyn 6/13/16: margin around globe when next to a border or text should be 1/2 the width of the image */
    height:100px
}
.footer_copy {
    margin-top:20px
}
.panel-body {
    min-width:600px
}
.newNavigation {
    font-family:inherit;
    position:relative;
    width:100%;
    background-color:#fff;
    height:74px
}
.newNavigation .navContainer {
    position:relative;
    top:21px;
    width:88%;
    margin:auto;
    background-color:white
}
.newNavigation .left {
    position:absolute;
    left:0px;
    width:20%
}
.newNavigation .right {
    position:absolute;
    right:0px;
    width:80%
}
.newNavigation .navigation-links {
    position:absolute;
    right:111px
}
.newNavigation .navigation-links li {
    display:inline-block;
    margin-right:15px
}
.newNavigation .navigation-links li a {
    color:#999 !important
}
.newNavigation .navigation-links li .cbp-hrsub {
    display:none
}
.newNavigation .mobileMenu-icon {
    border:1px solid silver;
    border-radius:3px;
    cursor:pointer;
    display:none;
    padding:9px 8px 0;
    position:absolute;
    right:111px;
    top:-5px;
    z-index:9999
}
.newNavigation .mobileMenu-icon .glyphicon {
    color:gray;
    display:block;
    font-size:350%;
    height:10px;
    line-height:0 !important
}
.hero-container { /* Robyn 5/16/16: updated class attributes per new style guidelines */
    width: auto !important;
    margin: 0 6% !important;
    float: left !important;
}
.hero-container .hero_badge_bg {
    top:-120px;
    background:#fff;
    opacity:.75;
    z-index:2
}
.hero-container .hero_down {
    float:right;
    position:relative;
    top:-28px;
    left:30px;
    width:44px;
    height:44px;
    background-position:-120px -240px;
    cursor:pointer
}
.hero-container .apply_now {
    position:relative;
    top:57px;
    padding:15px 45px;
    color:#fff;
    background:#0077b4;
    -webkit-transition:background 0.3s ease-in-out;
    -ms-transition:background 0.3s ease-in-out;
    -o-transition:background 0.3s ease-in-out;
    transition:background 0.3s ease-in-out;
    -webkit-border-radius:6px;
    border-radius:6px
}
.hero-container .apply_now:hover {
    color:#0e226c;
    text-decoration:none;
    background:#77b1d9
}
.hero_badge {
    position:relative;
    /* Robyn 6/10/16: hero style updates */
    /*top:150px;*/
    top: 72px;
    /*max-width:750px;*/ /* Robyn 5/5/16 removed attribute per new style guidelines */
    width:100%;
    padding:16px;
    /*background-color:rgba(255,
    255,
    255,
    0.7);*/
    background-color: #eee;
    border-radius: 4px;
    z-index:3
}
.hero_badge:after {
    content:"";
    display:table;
    clear:both
}


/* Robyn 6/8/16: update hero images */
/* products hero images */
/* yamini 8/30/2016:updated hero image for ASE */
/* yamini 09/12/2016:updated hero image for CWS */
/* Brandon 8/30/2016:updated hero image for SEG and WWAN*/
/* yamini 11/02/2016:updated hero image for COLO */
.wwan {background-image: url(hero_products/hero_products_wwan.jpg) !important;}
.ase {background-image: url(hero_products/hero_products_ase.jpg) !important;}
.netbond {background-image: url(hero_products/hero_products_netbond.jpg) !important;}
.anira {background-image: url(hero_products/hero_products_anira.jpg) !important;}
.avpn {background-image: url(hero_products/hero_products_avpn.jpg) !important;}
.eptt {background-image: url(hero_products/hero_products_eptt.jpg)}
.ia {background-image: url(hero_products/hero_products_aia.jpg) !important;}
.ifr {background-image: url(hero_products/hero_products_ifr.jpg) !important;}
.iot {background-image: url(hero_products/hero_products_iot.jpg)}
.mis {background-image: url(hero_products/hero_products_mis.jpg) !important;}
.mobile {background-image: url(hero_products/hero_products_mobile.jpg)}
.nfs {background-image: url(hero_products/hero_products_nbfw.jpg) !important;}
.colo {background-image: url(hero_products/hero_products_colo.jpg) !important;}
/* grow hero images */
.hero-grow-campaign {background-image: url(hero_grow/hero_grow_campaign_builder.jpg) !important;}
.hero-grow-proposal {background-image: url(hero_grow/hero_grow_proposal_builder.jpg) !important;}
.grow-getting-started {background-image: url(hero_grow/hero_grow_getting_started.jpg) !important;}
.grow-additional-resources {background-image: url(hero_grow/hero_grow_additional_resources.jpg) !important;}
.grow-development-funds {background-image: url(hero_grow/hero_grow_development_funds.jpg) !important;}
.grow-incentives {background-image: url(hero_grow/hero_grow_incentives.jpg) !important;}
.grow-marketing-guides {background-image: url(hero_grow/hero_grow_marketing_guides.jpg) !important;}
.grow-sharedvue {background-image: url(hero_grow/hero_grow_sharedvue.jpg) !important;}
.grow-enablement-directory{background-image: url(hero_grow/hero_grow_ed.jpg) !important;}
.hero-manage-network-services {background-image: url(hero_manage/hero_manage_network_services.jpg) !important;}
/* yamini 10/12/2016:updated hero image for ENABLEMENT-DIRECTORY */
.enablement-directory-hero { background-image: url(hero_grow/hero_grow_ed.jpg) !important; }

.hero-newsroom {background-image: url(hero_community/hero_community_newsroom.jpg) !important;}

.developer-overview {background-image: url(hero_developers/hero_developers_api.jpg) !important;}

/* product page styles  */
/* product elements */

.grow-body h2,
.products-body h2 {
    font-family: "omnes_light";
    font-size: 2.5em;
    /*color: #666; Robyn 4/10/16 removed color attribute to inherit default black color per defect 2156 */
    margin-bottom: 20px;
}
.grow-body h3, 
.products-body h3 {
    margin-bottom: 25px; /* Robyn 4/10/16: update marging bottom per styleguide v9 */
    font-family: "omnes_att_iimedium";
    font-size: 2em;
    color: #333;
}
.grow-body h4, 
.products-body h4 {
    font-family: "omnes_att_iimedium" !important;
    font-size: 1.125em !important;
    margin-bottom: 0px !important;
}
.grow-body h5, 
.products-body h5 {
    font-family: "omnes_att_iimedium";
    margin-bottom: 10px;
}
.grow-body .contentCol .details p, 
.grow-body .contentCol .training .details p.duration,
.products-body .contentCol .details p, 
.products-body .contentCol .training .details p.duration {
    margin-bottom: 0;
}
.grow-body .contentCol .training .details p, 
.products-body .contentCol .training .details p {
    margin-bottom: 20px;
}
.grow-body .leftNavCol, 
.products-body .leftNavCol {
    position:relative;
    height:auto !important;
    padding:34px 24px 24px 24px; /* Robyn 4/10/16: update per US600181 */
    text-align:left
}
.grow-body .leftNavCol .leftNav, 
.products-body .leftNavCol .leftNav {
    margin-left:21%;
    padding-top:20px;
    width:153px
}
.grow-body .leftNavCol .leftNav button, 
.products-body .leftNavCol .leftNav button {
    width:100%;
    display:block;
    font-size:1.1em;
    text-align:left;
    color:#009add
}
.leftNavCol .active {
    background-color: #0568ae; /* Robyn 4/10/16: color update to match styleguide v9 */
}
.leftNavCol .active a {
    color: #fff;
}
.grow-body .leftNavCol .dropdown-nav button, 
.products-body .leftNavCol .dropdown-nav button {
    left:0 !important;
    padding:12px;
    position:absolute !important;
    top:-3px !important;
    width:100% !important;
    font-size:1.25em
}
.grow-body .leftNavCol .dropdown-menu, 
.products-body .leftNavCol .dropdown-menu {
    position:absolute;
    top:47px;
    width:100% !important;
    font-size:1.25em !important
}
.grow-body .leftNavCol .dropdown-menu li a, 
.products-body .leftNavCol .dropdown-menu li a {
    border-bottom:1px solid #efefef;
    padding:15px !important;
    text-align:center
}
.grow-body .contentCol, 
.products-body .contentCol {
    height:auto !important;
    padding-top: 50px; /* Robyn 4/10/16: update padding per US600181 */
}

.grow-body .contentCol li, 
.products-body .contentCol li {
    line-height:1.75em;
    white-space:normal;
}
.grow-body .contentCol p, 
.products-body .contentCol p {
    line-height:1.6875em;
    margin-bottom: 20px;
}
.products-body .contentCol .view-all {
    text-align:center;
    padding-top:10px;
    padding-bottom:10px;
}
.overview section {
    margin-bottom:2.5em !important
}
.overview section .note {
    color:#999;
    text-decoration:italic;
    margin-bottom:10px
}
/*Use Case Table styles*/
table.productOverView_table_useCases {
    border: 1px solid #e9e9e9;
    background: #fff;
}
table.productOverView_table_useCases td {
    padding:20px;
}
.borderRight {
    border-right: 1px solid #e9e9e9;
}
table.productOverView_table_useCases th {
    font-weight: bold;
    text-align: center;
}
/* List Styles for Bullets, Dash and Numbered lists */
.grow-body ul, 
.grow-body ol, 
.products-body ul, 
.products-body ol {
    margin-bottom: 20px;
}
ol.numbered li {  
    list-style-type: decimal; 
    margin-left: 20px;
    margin-bottom:7px !important; 
    padding-left: 10px;
}
ul.bullets li {  
    list-style-type: disc; 
    margin-left: 20px; 
    margin-bottom:7px !important;
    padding-left: 10px;
}
ul.dash li {
    list-style-type: none;
    margin-left: 0;
    margin-bottom:7px !important;
    padding-left: 1em;
}
ul.dash li:before { 
    display: inline-block;
    content: "-";
    width: 1em;
    margin-left: -1em;
}

/*  SVG background images
====================================================
==================================================== */
.close_x,
.att_partner_exchange_logo,
.begin_quote_icon,
.course_modal_x,
.blue_arrow_down,
.expand_all,
.big_white_wifi,
.big_white_cloud,
.big_white_globe,
.blue_globe,
.blue_cloud,
.blue_wifi,
.blue_support,
.blue_doc,
.blue_core,
.completed_icon,
.ico_close,
.pdf_icon,
.search_button,
.reorder_btn,
.td_dropdown_arrow,
.td_down_arrow,
.upload_photo,
.left_wedge {
    position:relative;
    margin:0 auto;
    background-size:900px 900px;
    background-image:url(portalDesignImg/app_icons.svg),
    none
}
.ico_close {
    width:25px;
    height:23px;
    cursor:pointer
}
.progress_full,
.progress_2,
.progress_1 {
    position:relative;
    margin:10px auto 5px;
    width:82px;
    height:11px;
    background-size:82px 44px;
    background-image: url(portalDesignImg/meter.png), none;
}
.progress_2 {
    background-position:0 -11px
}
.progress_1 {
    background-position:0 -22px
}
.progress_sml_2,
.progress_sml_1,
.progress_sml_0 {
    width:53px;
    height:10px;
    background-size:53px 30px;
    background-image: url(portalDesignImg/meter_sml.png), none;
}
.progress_sml_1 {
    background-position:0 -10px
}
.progress_sml_0 {
    background-position:0 -20px
}

/*  RESPONSIVE MEDIA QUERIES
====================================================
==================================================== */
/* 1600
==================================================== */
/* Robyn 6/16/16: hero style updates */
@media all and (min-width: 1600px) {
    #slice_hero {
        height: 300px !important;
    }
    .hero_badge {
        top: 105px !important;
  }
}
/* 1400
==================================================== */
@media all and (min-width: 1400px) {
    #slice_hero {
        /* Robyn 6/16/16: hero style updates */
        height: 270px;
    }
    .hero_badge {
        top: 90px;
  }
}
/* 1300
==================================================== */
/* 1260
==================================================== */
/* 1200
==================================================== */
@media all and (max-width: 1200px) {
    /* Robyn 6/13/16: adjusting break point nav styles for new logo */
    /*.navbar-logo {
        width:50px;
        height:50px;
        overflow:hidden
    }*/
    .begin_quote_icon {
      display:block
    }
    .begin_quote_btn {
        width:43px;
        height:40px;
        overflow:hidden;
        display: block;
        margin-left: 0;
    }
    .user_welcome {
        display:none
    }
    .profile-dropdown-container {
      right: -10px !important;
    }
    /* END Robyn 6/13/16 */
    .my_current_courses,
    .available_courses {
        padding:0 40px
    }
    .blue_hero p {
        width:100%
    }
    .tabbed_menu li {
        padding:20px 40px
    }
    section.file-download {
        width:100% !important;
    }
    .nav>li>a {
    padding: 10px 12px;
    }
}

/* 1100
==================================================== */
@media all and (max-width: 1100px) {
    .tabbed_menu li {
        padding:20px 30px
    }
    .add_site_input_div .adjust-select-small {
        width:95%;
        margin-bottom:10px;
        margin-top:2px
    }
    #add_site_loc2 {
        width:95% !important;
        margin-left:0px
    }
}

/* 1000
==================================================== */
@media all and (max-width: 1000px) {
    /*.container {
        padding:0 20px;
        width:100% !important
    }*/
    /* Robyn 6/13/16: moved .user_welcome style to break point 1200 */
    /* Robyn 6/13/16: moved navbar styles up to break point 1000 */
    
    .navbar-collapse.collapse.in {
    overflow: visible !important;
    display: block !important;
    margin-top: -6px;
    margin-left: -10px;
    margin-right: -10px;
    height: auto !important;
    padding: 0px 10px 20px;
  }

    #top_nav_bar { height: 73px !important; }
    .navbar-header {
        float:none
    }
    .navbar-toggle {
        display:block
    }
    .navbar-collapse {
        border-top:1px solid transparent;
        box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.1)
    }
    .navbar-collapse.collapse {
        display:none !important;
        height:0px;
        overflow:hidden
    }
    .navbar-collapse.collapse.in {
        overflow-y:auto !important;
        display:block !important;
        overflow-x:visible !important;
        overflow-y:hidden !important
    }
    .navbar-nav {
        float:left
    }
    .navbar-nav>li {
        float:none
    }
    .navbar-nav>li>a {
        padding-top:10px;
        padding-bottom:10px;
        line-height:12px !important
    }
    /*#nav_desktop,
    .container,
    .navbar-default .navbar-collapse {
        height:auto !important
    }*/
    .container {
        padding-bottom:20px
    }
    .navbar-logo {
        overflow:visible
    }
    .navbar-right {
        float:left !important
    }

    .hero_col {
        width:100%
    }
    table {
        font-size:0.6875em !important
    }
    .reorder_btn {
        display:none
    }
}

/* 990
==================================================== */
@media all and (max-width: 990px) {
    .container,
    .navbar-default .navbar-collapse {
        height:70px !important
    }
    #nav_desktop { height: auto !important; width: 100%;}

    /* Robyn 6/13/16: moved .begin_quote_icon and .begin_quote_btn style to break point 1200 */
    
    .tabbed_menu li {
        padding:21px 20px;
        font-size:0.875em
    }
    .tabbed_menu li.active_tab:after {
        top:56px;
        left:70px !important
    }
    .upload_p {
        top:-60px;
        left:-4px
    }
    .notification_col {
        margin-top:40px;
        width:100%
    }
    #choose_file {
        float:none !important
    }
    .optional_permissions {
        display:none
    }
    .optional_permissions_mobile {
        display:block
    }
    .optional_permissions_mobile {
        border:1px solid #ccc;
        padding:20px
    }
    .optional_permissions_mobile header {
        top:5px
    }
    .optional_permissions_table {
        border:0
    }
    .optional_permissions_table td {
        padding:0px
    }
    .optional_permissions_checkgroup label {
        font-size:0.875em
    }
    .welcome_message {
        margin-top:40px;
        width:100%
    }
    .profile_row .left_wedge {
        display:none
    }
    #complete_registration_form .question_icon {
        top:398px
    }
    .file-download .details{
        width:100%
    }
    .tabbed_menu li {
    padding: 15px;
    font-size: 0.875em; }
  .tabbed_menu li.active_tab:after {
    top: 44px;
    left: 64px !important; }
}

/* 900
==================================================== */
@media all and (max-width: 900px) {
    /*
    Bootstrap override
    http://stackoverflow.com/questions/26389771/mobile-menu-toggle-bug-after-changing-bootstraps-mobile-nav-break-point/26392195#26392195
    */    
    /*.navbar-header {
        float:none
    }
    .navbar-toggle {
        display:block
    }
    .navbar-collapse {
        border-top:1px solid transparent;
        box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.1)
    }
    .navbar-collapse.collapse {
        display:none !important;
        height:0px;
        overflow:hidden
    }
    .navbar-collapse.collapse.in {
        overflow-y:auto !important;
        display:block !important;
        overflow-x:visible !important;
        overflow-y:hidden !important
    }
    .navbar-nav {
        float:left
    }
    .navbar-nav>li {
        float:none
    }
    .navbar-nav>li>a {
        padding-top:10px;
        padding-bottom:10px;
        line-height:12px !important
    }
    #nav_desktop,
    .container,
    .navbar-default .navbar-collapse {
        height:auto !important
    }
    .container {
        padding-bottom:20px
    }
    .navbar-logo {
        overflow:visible
    }
    .navbar-right {
        float:left !important
    }*/
    #top_nav_bar .search_button {
        float:left;
        top:5px;
        left:10px;
        margin-right:20px
    }
    .begin_quote_btn {
        left:0;
        margin-top:15px;
        margin-left:0;
        width:auto;
        height:auto;
        overflow:x
    }
    .user_welcome {
        display:block
    }

}

/* 850
==================================================== */
/* 800
==================================================== */
@media all and (max-width: 800px) {
    /*.tabbed_menu li {
        padding:15px;
        font-size:0.875em
    }
    .tabbed_menu li.active_tab:after {
        top:44px;
        left:64px !important
    }*/
}

/* 768 (Mobile Break)
==================================================== */
@media all and (max-width: 768px) {
    .cert_program_copy {
        margin-top:0;
        margin-bottom:60px
    }
    table {
        font-size:0.625em
    }
    .manage_user_name {
        width:25%
    }
    .manage_user_email {
        width:35%
    }
    .leftNav {
        display:none !important
    }
    .mobile-content-menu {
        display:block !important
    }
    /* Robyn 6/16/16: hero style updates */    
    .hero-container {
      margin: 0 10px !important;
    }
}

/* 740
==================================================== */
@media all and (max-width: 740px) {
    .tabbed_menu li {
        padding:15px 20px;
        float:none
    }
    li.active_tab {
        -webkit-border-radius:4px;
        border-radius:4px
    }
    li.active_tab:after {
        display:none
    }
    #slice_hero {
        /* Robyn 6/16/16: hero style updates */
        height: 200px !important;
    }
    .hero_badge {
        top: 61px !important;
  }
    h1.hero_badge_1 {
      font-size: 32px !important;
    }
    h2.hero_badge_2 {
      font-size: 14px !important;
    }
}
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
@media all and (max-width: 360px) {
    .hero_badge {
        top: 50px !important;
    }
    h1.hero_badge_1 {
      font-size: 26px !important;
    }
    h2.hero_badge_2 {
      font-size: 12px !important;
    }
}