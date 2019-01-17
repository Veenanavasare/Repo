ol,ul,li{
    list-style: none;
    margin: 0; 
} 

h1,
h2,
h3,
h4,
h5,
h6 {
    margin: 0;
}

/*BRANDON 6.14.2016 : Adding icon fonts*/
/*@font-face {
    font-family: 'Portal-Fonts';
    src:    url('/resource/1465940694000/icon_fonts/Portal-Fonts.eot?ho7d1w');
    src:    url('/resource/1465940694000/icon_fonts/Portal-Fonts.eot?ho7d1w#iefix') format('embedded-opentype'),
            url('/resource/1465940694000/icon_fonts/Portal-Fonts.ttf?ho7d1w') format('truetype'),
            url('/resource/1465940694000/icon_fonts/Portal-Fonts.woff?ho7d1w') format('woff'),
            url('/resource/1465940694000/icon_fonts/Portal-Fonts.svg?ho7d1w#Portal-Fonts') format('svg');
    font-weight: normal;
    font-style: normal;
}*/

/*.att-icon {*/
    /* use !important to prevent issues with browser extensions that change fonts */
    /*font-family: 'Portal-Fonts' !important;
    speak: none;
    font-style: normal;
    font-weight: normal;
    font-variant: normal;
    text-tr nsform: none;
    line-height: 1;*/

    /* Better Font Rendering =========== */
    /*-webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}*/

/* Force margins to match redlines and override default element styles */
.mt-0 {margin-top: 0px !important;}
.mt-10 {margin-top: 10px !important;}
.mt-15 {margin-top: 15px !important;}
.mt-40 {margin-top: 40px !important;}
.mt-25 {margin-top: 25px !important;}
.mb-25 {margin-bottom: 25px !important;}
.mb-30 {margin-bottom: 30px !important;}
.mb-40 {margin-bottom: 40px !important;}
.mb-50 {margin-bottom: 50px !important;}
.mb-0 {margin-bottom: 0px !important;}
.mb-10 {margin-bottom: 10px !important;}
.mb-15 {margin-bottom: 15px !important;}
.h-202 {height: 202px !important;}

.spacingContent {
    padding-bottom: 40px;
}

/* PRODUCT PAGES */
/*.enablement-directory-hero { background-image: url("hero_products/hero_products_ed.jpg"); }*/
.enablement-disclaimer { 
    font-size: 12px;  
    text-align: justify;
}
.product-page .transp-bg { background-color: rgba(0,0,0,0.3); }
.product-page .page-include { display: none; }
.product-page .PortalDesign_AVPN_Overview { display: block; }
.product-page .PortalDesign_IOT_Overview {display: block;}
.product-page .product-page #akvideo { position: relative; } 
.product-page .poster {
    width: 100%; 
    position: absolute; 
    top: 0px; 
    left: 0px;
    z-index: 100;
    cursor: pointer;
}
/*12/22/2016 YAMINI:Updated styles to the unclickable promo */
.unclickable{
           border: 2px solid #71c5e8;
           margin: 0 0 10px 0;
           padding:15px 10px 10px 10px ;
           min-height :182px;
           border-radius: 4px
        }
.unclickable-med {
    min-height: 200px;
}
.unclickable-lg {
    min-height: 220px;
}
.product-page .unclickable .att-icon{
    color: #71c5e8;
    font-size: 60px;
    position: relative;
    width: 90px;
    height: 60px;
}
.products-body .unclickable h4{
    font-size: 1em !important;
    margin: 15px 0 10px 0 !important;
    line-height: 1em;
}
.unclickable p {
    font-size: 14px;
    line-height: 1.2em !important;
    margin-bottom: 0px !important;
}
.product-page .unclickable.promo {
    background-color: transparent;
    border: 2px solid #71c5e8;
    color: #000;
}

/*.product-page .overview .att-icon-smartphone,
.product-page .att-icon-us { font-size: 290% !important; }*/

.product-page .arrow-down.arrow-down-l-bl { border-top: 20px solid #4e89a1 !important; } 
.product-page .arrow-down.arrow-down-gr { border-top: 20px solid #686868 !important; }
.product-page .arrow-down.arrow-down-d-bl { border-top: 20px solid #034879 !important; }
.product-page .arrow-down.arrow-down-bl { border-top: 20px solid #006e98 !important; }
.product-page .arrow-down.arrow-down-d-gr { border-top: 20px solid #3e3e3e !important; } 
.product-page .IRUMultipleCustomers {
    padding-top: 2px; 
    padding-bottom: 2px; 
}


/* Section Headings */
/* overwrites h3 style in App_CSS, updated font-size for h3 section headings */


.bg-heading {
    position: relative;
    margin-left: 45px;
    font-size: 1.7em !important;
}

.product-page .min5 {
    font-size: 80%;
    position: relative;
    top: -8px;
}

.product-page .promo-link {
    position: relative;
    padding-top: 16px !important;
    color: #fff !important;
}
.product-page .promo {
    padding-bottom: 81px !important;
    padding-top: 40px !important;
    height: 152px !important;
}
.product-page .promo-link span {
    position: absolute; 
    bottom: 0px; 
    width: 100%;
}

.product-page .promo-link.active:after {
    position: absolute;
    bottom: -14px; 
    left: 50%;
    margin-left: -20px; 
    content: "";
    width: 0; 
    height: 0; 
    border-left: 20px solid transparent;
    border-right: 20px solid transparent;
    border-top: 20px solid #00688f;
    z-index: -1;
}
.product-page .promo-link.active.blue-arrow:after { border-top: 20px solid #006f99 !important; }
.product-page .promo-link.active.dk-blue-arrow:after { border-top: 20px solid #00467b !important; }
.product-page .promo-link.active.gray-arrow:after { border-top: 20px solid #686868 !important; }
.product-page .promo-link.active.dk-gray-arrow:after { border-top: 20px solid #3e3e3e !important; }
.product-page .promo-link.active.lt-blue-arrow:after { border-top: 20px solid #4e89a1 !important; }
.product-page .promo-link.active.lt-gray-arrow:after { border-top: 20px solid #939393 !important; }
.product-page .promo-link.active.md-lt-gray-arrow:after { border-top: 20px solid #868686 !important; }
.product-page .learn-more {
    padding-top: 10px !important; 
    padding-bottom: 10px !important; 
}
.product-page .promo .att-icon {
    display: inline-block;
    font-size: 60px;
    position: relative;
    top: -15px; 
    color: #fff;
    width: 90px;
    height: 60px;
}

.product-page .unclickable .att-icon {
    color: #71c5e8;
}

.product-page .promo-link .att-icon { color: #fff; }

.product-page .stepCont { margin-top: -56px; }
.product-page .stepCont h3 {
    padding-top: 20px; 
    padding-bottom: 20px; 
}

.promo-link h3 {
    color: #fff !important;
}

.product-page h3 p { 
    font-size: 16px; 
    font-family: "omnesatt_iiregular";
    margin-bottom: 0px !important; 
}

.product-page .video-desc-title {
    color: #3bc1f4;
}
/* Phani: 11/18/2016: Updating IFR_Overview; */
/* yamini:11/16/2017:updating ; */
.product-page .PortalDesign_MIS_Overview,
.product-page .PortalDesign_ASE_Overview,
.product-page .PortalDesign_SEG_Overview,
.product-page .PortalDesign_WWAN_Overview,
.product-page .PortalDesign_IFR_Overview{ display: block; }
.product-page .PortalDesign_AVPN_Overview{ display: block; }
.product-page .PortalDesign_CWS_Overview{ display: block; }
.product-page .PortalDesign_NetBond_Overview{ display: block; }
.product-page .PortalDesign_ANIRA_Overview{ display: block; }
.product-page .PortalDesign_NFS_Overview{ display: block; }
.product-page .PortalDesign_COLO_Overview{ display: block; }
.product-page .PortalDesign_IA_Overview{ display: block; }
.product-page .PortalDesign_FS_Overview{ display: block; }
.product-page .PortalDesign_Developers_Overview { display: block; }
.product-page .PortalDesign_FlexWare_Overview{ display: block; }
.product-page .PortalDesign_FlexWare_Overview{ display: block; }
.product-page .PortalDesign_DedicatedEthernet_Overview{ display: block; }
/* Phani: 11/18/2016: End of changes; */
.product-page .Grow_MarketingTools_CoBranding {
    display: block;
}

.product-page .Grow_DevelopmentFunds_Overview {
            display: block; !important
        }

.product-page .Grow_MarketingGuides_BrandAssets_Badges{ display: block; !important}
.product-page.Grow_MarketingGuides_BrandAssets{ display: block; }
.product-page .Grow_Incentives_IncentivesPromotions{ display: block; }
.product-page .Grow_MarketingGuides_BrandGuidlines{display:block;}
.product-page .PortalDesign_GettingStarted_Overview {display:block;}
.product-page .Grow_AdditionalResources_APIS{display:block;}
.product-page .Grow_MarketingGuides_BrandAssets_Logos{ display: block; !important}
.product-page.enable-directory {

}

/*///////////   End Product Pages   ////////////*/

/* Robyn 6/6/16: Temp style to demo what new hero size looks like need to stick to old naming convention if green lighted */
/*.ifr-new {background-image: url(heroesNew/hero_products_ifr-new.jpg)}
.mobile-new {background-image: url(heroesNew/hero_products_mobile-new.jpg)}
.iot-new {background-image: url(heroesNew/hero_products_iot-new.jpg)}
#slice_hero.hero_new {height: 233px !important;}
.hero_badge.hero_new {top:87px !important; border-radius: 4px !important; background-color: rgba(255, 255, 255, 1) !important;}*/

/* ATT Colors for background-color Declarations */

.blue {color: #009fdb;} 
.bg-blue {background-color: #009fdb;}
.bg-blue-deep {background-color: #00688f;}

.bg-lt-blue {background-color: #71c5e8;}
.bg-lt-blue-deep {background-color: #4a8097;}

.bg-dk-blue {background-color: #0568ae;}
.bg-dk-blue-deep {background-color: #034471;}

.gray, h3.gray {color: #959595;} /* needed to overwrite style in App_CSS */
.bg-gray {background-color: #959595;}
.bg-gray-deep {background-color: #616161;}
.bg-lt-gray {background-color: #d2d2d2;}
.bg-lt-gray-deep {background-color: #7c7c7c}

.bg-dk-gray {background-color: #5a5a5a;}
.bg-dk-gray-deep {background-color: #3f3f3f;}

.bg-md-lt-gray {background-color: #bfbfbf;}

/* Robyn 6/8/16: moved hero styles to App_CSS */


.section-indent {margin:0 25px;}

/* Template Names */
/* Template: Marketing Page // Full-width Container (single column, i.e. Grow > Campaign Builder) */

.temp-mkt-full-width {margin:0 6%;} /* developers note: this template is based on how hero images are structured out, really should be improved for proper bootstraph layout */

/* Overwrite styles in App_CSS */
sup { 
    left: -0.1em !important; 
}

/* Left side nav styles */
.mobile-leftNav {width: 185px !important;}
.leftNav ul li a.btn-link {
    width: 100%;
    text-align: left;
}
.leftNav-sub {
        display: none;
        margin-bottom: 0;
}

.leftNav-sub li.active a {
    /*color: #428bca;*/
}

li[data-sub] {
    position: relative;
}

li[data-sub]:after {
    position: absolute; 
    top: 10px; 
    right: 15px; 
    color: #0568ae;
    content:'';
    width: 0; 
    height: 0; 
    border-top: 7px solid transparent;
    border-bottom: 7px solid transparent;
    border-left: 7px solid #0568ae;
}

li[data-sub].active:after  {
    top: 15px;
    border-top: 0px solid transparent;
    border-bottom: 0px solid transparent;
    border-right: 7px solid transparent;
    border-left: 7px solid transparent;
    border-top: 7px solid #fff;
}


.active-with-sub:after  {
    position: absolute; 
    top: 15px !important; 
    right: 15px; 
    color: #0568ae;
    width: 0; 
    height: 0; 
    border-top: 0px solid transparent !important;
    border-bottom: 0px solid transparent !important;
    border-right: 7px solid transparent !important;
    border-left: 7px solid transparent !important;
    border-top: 7px solid #0568ae !important;
}

.active-without-sub:after  {
    position: absolute; 
    top: 10px !important; 
    right: 15px; 
    width: 0; 
    height: 0; 
    border-top: 0px solid transparent !important;
    border-bottom: 0px solid transparent !important;
    border-top: 7px solid transparent !important;
    border-bottom: 7px solid transparent !important;
    border-left: 7px solid #fff !important;
}
.learnmore-li.active a, 
.learnmore-li.active.active-with-sub {padding-top: 4px;}
.learnmore-li.active, 
.sub-open {
    border-top: 2px solid #0568ae;
}
ul#learnmore-sub {
    margin-bottom: 0;
}
ul#learnmore-sub li a { padding-left: 25px;}
ul#learnmore-sub li:last-child {border-bottom: 2px solid #0568ae;}

.new-thanks,
.existing-thanks {
    display: none;
}


ul.bullet-cir-list {
    margin: 20px 0 40px 0px !important;
}
.bullet-cir {
    float: left;
    margin-right: 10px;
    border-radius: 50%;
    width: 30px;
    height: 30px;
    color: #fff;
    line-height: 26px;
    text-align: center;
    font-size: 20px;
    margin-top: -2px;
}
.bullet-cir-list p {
    line-height: 1.4em !important;
}
.bullet-cir-list p span {
    font-family: 'omnes_att_iimedium';
    font-size: 22px;
   /* color: #d1d1d1; */
    color: #959595;
}


/* overwrites App_CSS line-height for p element on existing grow and product pages */ 
.grow-body .contentCol p, .products-body .contentCol p {
    line-height: 1.2em !important;
}

/* Page Heading */
/* overwrites h2 style in App_CSS for existing grow and product pages */
.grow-body h2, .products-body h2 {
    font-size: 32px !important; 
    margin-bottom: 40px !important;
}

h2.modal-title {
    margin-bottom: 0 !important;
    color: #000 !important;
}

.grow-body h4.form-heading, .products-body h4.form-heading {
    margin: 30px 0 20px 0 !important;
}
.modal-header,
.modal-footer,
.modal-body {
    padding: 30px 60px !important;
}
.modal-header, 
.modal-footer, 
.gray-hr {
    border-color: #959595 !important;
}
.modal-body p {
    margin-bottom: 20px;
    line-height: 1.2em;
}
.modal-body h5 {margin: 30px 0 20px 0 !important;}

.step-body .modal-content, 
.grow-body .modal-content {
    text-align: center;
    background-color: #f7f7f7;
}

.infographic {
    margin-top: 70px;
    width: 70%;
    border-radius: 4px; 
    webkit-box-shadow: 0px 0px 5px 1px rgba(122,122,122,.5);
    -moz-box-shadow: 0px 0px 5px 1px rgba(122,122,122,.5);
    box-shadow: 0px 0px 5px 1px rgba(122,122,122,.5);
}

.control-label {
    font-family: 'omnes_att_iimedium';
    margin-bottom: 5px;
    font-weight: normal !important;
}

.iru-checkbox {
    width: auto;
    height: auto;
    margin: 4px 4px 0 0 !important;
    float: none;
}
.help-text {
    font-size: .8em;
}
label.iru-checkbox-label {
    font-family: 'omnesatt_iiregular';
}
.check-group {
    display: block;
    margin-bottom: 5px;
}
input.sponsorship-att,
input.discount-att,
input.regSheet-att {
    border: 0;
    border-radius: 0;
    padding: 0;
}

input.submit-button,
button.cancel-button,
.btn-primary {
    width: auto;
    font-family: 'omnes_att_iimedium';
    height: 40px;
    font-size: 16px !important;
    border: 0 !important;
}
.btn-primary:hover {
    background-color: #70c4e8 !important;
}
input.submit-button,
.btn-primary {
    min-width: 175px;
    background-color: #0568ad !important;
}
button.cancel-button {
    background: none !important;
    margin-right: 50px;
    color: #0568ad;
    padding: 0;
}
button.cancel-button:hover {
    color: #70c4e8;
    border: 0 !important;
}
.btn.disabled, .btn[disabled], fieldset[disabled] .btn {
    background-color: #cecece !important;
}


/* Section Headings */
/* overwrites h3 style in App_CSS, updated font-size for h3 section headings */
.grow-body h3, .products-body h3 {    
    font-size: 22px !important;
}

.bg-heading {
    position: relative;
    margin-left: 45px;
    font-size: 1em !important;
}
.bg-heading img {
    top: -8px;
    position: absolute;
    width: 40px;
    height: 40px;
    left: -49px;
}
.doc-sub-cat {
    font-size: 16px;
    display: block;
    margin-bottom: 20px;
    line-height: 1.2em;
}

/* Promo Card Styles */
.promo-row {
    margin-right: -5px !important; 
    margin-left: -5px !important;
}
.promo-col {
    padding-right: 5px !important; 
    padding-left: 5px !important;
}

.promo-col a {
    position: relative;
}
.promo {
    border-radius: 4px;
    padding: 10px 15px;
    color: #fff;
    min-height: 190px;
    /*margin: 20px 0 40px 0;*/
}
.promo.eptt {
    /*min-height: 165px !important;
    margin-bottom: 10px*/
}
.grow-body .promo h4,
.products-body .promo h4 {
    font-size: 1em !important;
    margin: 5px 0 10px 0 !important;
    line-height: 1em;
}

.promo p {
    font-size: 14px;
    line-height: 1.2em !important;
    margin-bottom: 0px !important;
}

.promo img {
    margin: 0 auto;
     
}



.learnMore-link {
    position: absolute;
    border-top: 2px solid #fff;
    margin-left: -10px;
    width: 100%;
    bottom: 0px; 
    padding: 2px 0px 5px 0px !important; 
    margin-top: 7px !important;
    background-color: rgba(0,0,0,.3);
    border-bottom-right-radius: 4px; 
    border-bottom-left-radius: 4px; 
}

.rate-plans .promo {
    min-height: 330px; /* makes all promo columns min-height, need to add auto heigh detection for row */
}
.benefits .promo {
    min-height: inherit; /* removes min-height declared for .promo */
    padding: 0; 
    background: none;
}
.ico-ben {
    width: 64px;
    margin-right: 40px;
    display: table-cell;
    vertical-align: middle;
}

/* Video library section on Mobile/Learn More/Training page */
.video-list-wrapper {
    background: #fff;
    border-radius: 4px;
    border: 1px solid #d2d2d2;
}
h3.video-list-heading {
    color: #fff !important;
    padding: 15px;
    border-bottom: 1px solid #d2d2d2;
    margin-bottom: 0px !important;
}
/*ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
}*/
ul.video-list {
    height: 240px;
}
 ul.video-list li {
    background-image: url(ImgStatic/bullet-video.svg);
   background-repeat: no-repeat;
    background-position: 15px center;
    padding: 22px 0px 22px 65px;
    line-height: 1.25em !important;
    min-height: 31px;
    background-size: 12%;
} 

ul.video-list .li1 {
    background-image: url(ImgStatic/bullet-video.svg);
   background-repeat: no-repeat;
    background-position: 15px center;
    padding: 22px 0px 22px 65px;
    line-height: 1.25em !important;
    min-height: 31px;
    background-size: 12%;
}
ul.video-list .li2 {
    background-image: url(ImgStatic/bullet-microphones.svg);
   background-repeat: no-repeat;
    background-position: 15px center;
    padding: 22px 0px 22px 65px;
    line-height: 1.25em !important;
    min-height: 31px;
    background-size: 12%;
} 

ul.video-list li:not(:last-child) {
    border-bottom: 1px solid #e7e7e7;
}

.video-desc {
    margin: 20px 0;
}
.video-link {
    font-size: 16px;
    cursor: pointer;
}

.promo.eptt .ben-desc {width: 160px;}
.ben-desc h4 {font-size: 1.2em !important;}

/* applications benefits list */
.app-benefits .promo {
    border-radius: 4px;
    background-image: url(ImgStatic/border-blue-vert.png);
    background-repeat: repeat-y;
    background-position: 100px;
    padding: 25px 5px 25px 25px;
    min-height: 120px
}
.app-benefits .promo .ico-ben {margin-right: 23px;}
.app-benefits .promo .ben-desc {
    margin-top: 5px;
}
.grow-body .app-benefits .promo h4,
.products-body .app-benefits .promo h4 {
    font-size: 22px !important;
    margin-bottom: 5px !important;
    line-height: 1em;
}

.app-benefits .eptt .promo {
    padding: 15px 5px 15px 25px;
}


/* updated version of the benefits list on EPTT Overview, fixes for responsiveness */
.eptt-promo-table {
    max-width:952px; 
    margin-left:-10px;
}
.eptt-promo-table .ben-desc {
    text-align: left;
}
.vert-border-promo-table { 
    display: table; 
    border-collapse: separate; 
    margin: 0 auto; 
    border-spacing: 10px 5px;
    overflow: hidden;
    position: relative;
}
.benefits { 
    display: table-row; 
    height: 145px;
}
.benefits-li { 
    display: table-cell; 
    vertical-align: middle;
    border-radius: 4px;
    background-image: url(ImgStatic/border-wht-vert.gif);
    background-repeat: repeat-y;
    background-position: 100px;
    padding: 10px 0;
}
.promo.eptt {
    display: table;
    border-collapse: separate !important;
    border-spacing: 30px 0px !important;
    margin: 0px -5px;
}
.li-table-row {display: table-row;}
.ben-desc {
    display: table-cell;
    vertical-align: middle;
}
.ico-ben img {
    margin-left: -5px;
     width: 90px;
height: 60px;
}  


.promo-link {
    display: block;
    color: #fff !important;
    padding: 10px 10px 0 10px;
    margin-bottom: 10px;
    min-width: 1%;
}
a.promo-link:hover {
    color: #fff !important;
    text-decoration: none !important;
}
.promo-link span {
    display: block;
    margin: 20px -10px 0 -10px;
    padding: 5px 0px;
    border-top: 2px solid rgb(247, 247, 247);
    border-bottom-left-radius: 4px;
    border-bottom-right-radius: 4px;
}
.promo-border {
    display: block;
    border-top: 2px solid #fff;
    margin: 10px -10px;
}

.promo .footnotes {
    margin: 0;
    text-align: left;
}

.learn-banner {
    background-color: #fff;
    border: 1px solid #d2d2d2;
    border-radius: 4px;
    padding: 15px;
    margin-bottom: 40px;
}
.learn-banner .bg-globe {
    background: url(ImgStatic/bg-globe.png) no-repeat 15px 0;
    min-height: 60px;
   
}
.learn-banner .bg-help {
    background: url(ImgStatic/ico-file-help.png) no-repeat 15px 0;
    min-height: 60px;
   
}
.learn-banner .banner-content {
    margin-left: 75px;
}
.learn-banner p {
    margin: 5px 0 0 0 !important;
    font-size: 13px;
    font-family: 'omnes_light';
    color: #959595;
}
.learn-banner button {
    margin-top: 10px;
}

.callout-graphic-list {
    margin-bottom: 30px;
}

.callout-graphic-list img {
    margin: 0 0 0 60px;
}

.callout-graphic-list ul {
    font-family: 'omnes_att_iimedium';
    font-size: 22px;
    margin: 30px 0 0 20px;
}

.callout-circle-steps {margin-bottom: 0 auto !important;}
.callout-circle-steps .callout-step {
    background: url(ImgStatic/bg-callout-circle-list.png) no-repeat 0;
    width: 142px;
    height: 142px;
    padding-top: 45px;
    float: left;
}
.callout-circle-steps .arrow {
    background: url(ImgStatic/ico-arrow-right.png) no-repeat 0 10px;
    width: 33px;
    height: 58px;
    margin: 30px 10px 0 10px;
    float: left;
}


.callout-circle-list {
    margin: 40px 0;
}
.callout-circle-list ul.mobile-view {
    display: none;
}
.callout-circle-list li {
    background: url(ImgStatic/bg-callout-circle-list.svg) no-repeat 0;
    width: 142px;
    height: 142px;
    padding: 55px 0 0 0;
    margin-left: 20px;
    background-size: 100%;
background-repeat: no-repeat;
}


.callout-circle-list.circle-steps li {
    padding: 40px 0 0 0;
    margin-left: 0;
}
.callout-circle-list.circle-steps ul li.arrow {
    background: url(ImgStatic/ico-arrow-right.svg) no-repeat 0;
    width: 33px;
    height: 48px;
    margin: 0 5px;
    background-size: 70%;
    background-repeat: no-repeat;
}
}


.callout-circle-list.get-started li {
    padding: 40px 0 0 0;
}
.callout-circle-list li:first-child {
    margin-left: 0;
} 

/* Footnote/Disclaiming Styles */
.footnotes {
    margin-top: 40px;
}
ol.numbered.footnotes li {
    margin-bottom: 5px !important;
    font-size: 12px;
    line-height: 1em;
}

.manage-funds-callout {
    display:table;  
    width:100%; border: 1px solid #d2d2d2; 
    padding: 20px; 
    background-color: #fff; 
    min-height: 85px; 
    background-image: url(ImgStatic/border-doc-file.gif); 
    background-repeat: repeat-y;
    background-position: 215px;
}
.manage-funds-btn {
    min-width: 175px;
    float: left; 
    display: table-cell; 
    margin: 0 40px 0 0;
}
.manage-funds-txt {
    display: table-cell;
    font-family: 'omnes_att_iimedium' !important;
    font-size: 1.125em !important;
    vertical-align:middle;
}

.manage-funds-disabledtxt {
    display: table-cell;
    font-family: 'omnes_att_iimedium' !important;
    font-size: 1.125em !important;
    vertical-align: middle;
    color: #d1d1d1;
}
.manage-funds-disabledbtn:hover {
border:1px solid #595959; 
 color: #595959;
    background-color: #d1d1d1;
    padding:9px 19px;
    cursor: not-allowed;


}
  
  .manage-funds-disabledbtn {
    min-width: 175px;
    float: left;
    display: table-cell;
    margin: 0 40px 0 0;
    background-color: #d1d1d1;
    cursor: default;
}

/* Document List Styles */
/* new styles to replace styles for section.file-download, will remove that class when all document lists have been added to controller for mgmt */ 
.document-file {
    background-color: #fff;
    background-image: url(ImgStatic/border-doc-file.gif);
    background-repeat: repeat-y;
    background-position: 83px;
    border: 1px solid #d2d2d2;
    margin-bottom: 20px !important;
    display: table;
    padding: 15px;
    width: 100%;
}
.document-row {display: table-row;}
.products-body .document-file h4,
.document-file h4 {margin-bottom: 5px !important;}
.document-file p {
    color: #333;
    margin: 0;
    line-height: 1.3em;
}
.document-file .file-type {
    width: 90px;
    display: table-cell;
    height: 58px;
}

.document-file .file-pdf {
    background: url(ImgStatic/ico-file-pdf.png) no-repeat 5px center;
}
.document-file .file-docx {
    background: url(ImgStatic/ico-file-docx.png) no-repeat 5px center;
}
.document-file .file-zip {
    background: url(ImgStatic/ico-file-zip.png) no-repeat 5px center;
}
.document-file .file-xlsx {
    background: url(ImgStatic/ico-file-xls.png) no-repeat 5px center;
}
.document-file .file-xlsb{
    background: url(ImgStatic/ico-file-xlsb.png) no-repeat 5px center;
}
.file-URL {
    background: url(ImgStatic/ico-file-help.png) no-repeat 5px center !important;
}
.file-jpg {
    background: url(ImgStatic/ico-file-photos.png) no-repeat 5px center !important;
}
.document-file .details {
    display: table-cell;
    vertical-align: top;
    width: auto;
    float: none;
}

/* Tabbed Steps for Mobile > Start Selling */



.step-tab-container {
    display: table;
    border-collapse:separate !important;
    border-spacing: 10px !important;
    margin: 0 -10px !important;
}
.startselling .step-tab-container {
    margin: 0 -25px;
}
.step-tab-list {
    color: #fff;
    display: table-row;
}
.stepTab {
    position: relative;
    display: table-cell;
    float: none !important;
}
.step-tab-list .step {
    background: url(ImgStatic/bg-step-circle-list.svg) no-repeat 0;
    width: 59px;
    height: 59px;
    display: block;
    margin: 10px auto 20px auto;
    padding-top: 15px;
    font-size: 32px;
    background-size: 100%;
background-repeat: no-repeat;
} 
.step-tab-list .border {
    display: block;
    border-top: 2px solid #fff;
    margin: 10px -10px;
}
.step-tab-list h4,
.grow-body .step-tab-list h4, .products-body .step-tab-list h4 {
    font-family: 'omnes_att_iimedium';
    margin: 0 0 10px 0 !important;
    line-height: 1.2em !important;
}
.step-tab-list p {
    font-size: 14px;
    line-height: 1.4em !important;
    margin-bottom: 0 !important;
}

.stepCont {
    display: none;
    margin-top: -40px;
    margin-bottom: 40px;
}
.stepActive {
    display: none;
}

.arrow-down {
    position: absolute;
    width: 0px;
    height: 0px;
    border-left: 20px solid transparent;
    border-right: 20px solid transparent;
    /*border-top: 20px solid;*/
    bottom: -20px;
    left: 40%;
}
.arrow-down.arrow-down-gr {border-top: 20px solid #959595;}
.arrow-down.arrow-down-d-bl {border-top: 20px solid #0568ae;}
.arrow-down.arrow-down-l-bl {border-top: 20px solid #71c5e8;}
.arrow-down.arrow-down-d-gr {border-top: 20px solid #5a5a5a;}
.arrow-down.arrow-down-bl {border-top: 20px solid #009fdb;}

.step-heading {
    padding: 15px 30px;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
    color: #fff !important;
    margin-bottom: 0 !important;
}
.step-body {
    background: #fff;
    padding: 15px 30px;
    border-bottom-right-radius: 4px;
    border-bottom-left-radius: 4px;
    border-left: 1px solid #959595;
    border-bottom: 1px solid #959595;
    border-right: 1px solid #959595;
}

#step1,
#step2,
#step3,
#step4,
#step5 {
    padding: 10px;
    border-radius: 4px; 
    cursor: pointer;
    margin-left: 1%;
    width: 19.2%; 
    float: left;
    position: relative;
}
#step1 {margin-left: 0;}


/* 1500
==================================================== */
/* Force pages static and technical resources tabbed content styles */
@media only screen and (min-width: 1500px) {
    .paraSet{
        min-height: 32px;
    }
}
@media all and (max-width: 1500px) {
   .callout-circle-list.circle-steps ul li {
        background: url(ImgStatic/bg-callout-circle-list.png) no-repeat 0;
        background-size: contain;
        width: 120px;
        height: 120px;
        padding: 35px 0 0 0;
        font-size: 14px;
        font-family: "omnes_att_iimedium";
        line-height: 1.5em !important;
    } 
    .callout-circle-list.circle-steps ul li.arrow {
        background: url(ImgStatic/ico-arrow-right.png) no-repeat 0;
        background-size: contain;
        width: 23px;
        height: 36px;
        margin: 0 3px;
    }
}
/* 1260
==================================================== */
@media all and (max-width: 1260px) {
   .callout-circle-list.circle-steps ul {
        display: none;
   }
   .callout-circle-list.circle-steps.circle-steps-mobile ul {
        display: block;
   }
   .callout-circle-list li {
        background: url(ImgStatic/bg-callout-circle-list.png) no-repeat 0;
        background-size: contain;
        width: 120px;
        height: 120px;
        padding: 45px 0 0 0;
        margin-left: 15px;
    }
    .callout-graphic-list img {
        margin: 0;
    }
    .callout-graphic-list ul {
        font-size: 18px;
        margin: 40px 0 0 20px;
        }
    /* Promo Card Styles */
    
}
/* 1060
==================================================== */
@media all and (max-width: 1060px) {
    .callout-circle-list li {
        background: url(ImgStatic/bg-callout-circle-list.png) no-repeat 0;
        background-size: contain;
        width: 110px;
        height: 110px;
        padding: 40px 0 0 0;
        margin-left: 10px;
        font-size: 13px;
        font-family: "omnes_att_iimedium";
    }
}
/* 1205
==================================================== */
@media all and (max-width: 1205px) {
   .callout-circle-list.circle-steps ul.mobile-view {
        display: block;
    }
    .callout-circle-list.circle-steps ul.main-view {
        display: none;
    }
   .callout-circle-list.circle-steps ul li {
        background: url(ImgStatic/bg-callout-circle-list.png) no-repeat 0;
        background-size: contain;
        width: 120px;
        height: 120px;
        padding: 35px 0 0 0;
        font-size: 14px;
        font-family: "omnes_att_iimedium";
        line-height: 1.5em !important;
    } 
    .callout-circle-list.circle-steps ul li.arrow {
        background: url(ImgStatic/ico-arrow-right.png) no-repeat 0;
        background-size: contain;
        width: 23px;
        height: 36px;
    }
    
}


/* 1185
==================================================== */
@media all and (max-width: 1185px) {
    .promo {
        min-height: 145px;
        margin: 0 0 10px 0;
    }
}


.pb-190 {padding-bottom: 190px !important}

/* 960
==================================================== */
@media all and (max-width: 960px) {
    .callout-circle-list ul.mobile-view {
        display: block;
    }
    .callout-circle-list ul.main-view {
       display: none;
    }
}


.feature-list-container,
.feature-list-container-mobile {
    border-collapse: separate !important;
    border-spacing: 5px !important;
    margin: 0 auto;
    width: 80%;
}
.feature-list-container {
    display: table;
}
.feature-list-container-mobile {
        display: none;
    }
.feature-list {
    display: table-row;
    font-family: 'omnes_att_iimedium';
}
.feature-list li {
    display: table-cell; 
    float: none !important;
    width: 60px;
height: 90px;

}
.feature-list span {
    font-size: 55px;
    position: relative;
    top: -15px;
}

/* 600
==================================================== */
@media all and (max-width: 600px) {
    .feature-list-container {
        display: none;
    }
    .feature-list-container-mobile {
        display: table;
    }
    .feature-list li {
        font-size: 12px;
    }
    .document-file {
        background-image: none !important;
    }
    .document-file .file-type {
        width: 0 !important;
    }
}