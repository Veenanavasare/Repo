$(document).ready( function () {
           (function (){
             var leftNav = {
                  Init: function () {
                      this.CacheDom();
                      this.BindEvents();
                      this.GetHash();
                      this.HashListener();
                      this.InitStatus();
                      this.StickyNav();
                  },
                  CacheDom: function () {
                      $linkItem       = $(".mainLinks li").not(".leftNav-sub li");
                      $dataPage       = $("a[data-page], li[data-page], p[data-page], div[data-page]");
                      $active         = $(".mainLinks .active");
                      $subItem        = $(".leftNav-sub li, .leftNav-sub li a");
                      $subTrigger     = $("[data-sub]");
                  },
                  BindEvents: function () {
                      $subTrigger.on( "click", function () {
                          var myStatus = $(this).attr("data-status");
                          $(".leftNav-sub li.active").removeAttr("class");
                      });
                      $linkItem.on( "click", function () { 
                          console.log($(this));
                          // $(".active-with-sub").removeClass("active-with-sub");
                          leftNav.CheckNavStatus( $(this) );                        
                          leftNav.CloseAll( $(this), null );
                      });
                      $(document).delegate("[data-page]", "click", function () {
                          var myPage = $(this).attr('data-page');
                          window.location.hash = myPage;
                          leftNav.ScrollContTop();
                          // if (!$(this).hasClass("leftNav-sub")){
                          //     // leftNav.Open( null, $(this) , $(".leftNav-sub [data-page='"+myPage+"']").parents(".leftNav-sub") ); 
                              

                          //     // leftNav.CloseAll( null, $(".leftNav-sub [data-page='"+myPage+"']").parents(".leftNav-sub").siblings(".leftNav-sub") );
                          //     // leftNav.CloseAll( null, null );
                          // }
                          // if ($(this).hasClass("leftNav-sub")){
                              // $active.removeClass( "active" );
                              
                              // leftNav.CloseAll( $this, null );
                          // }
                          
                      });
                      $subItem.on( "click", function () {
                          var myTrigger = $(this).parent("ul").attr("id");
                          $("li.active").not($(this)).removeClass("active");
                          $("[data-sub='"+myTrigger+"']").addClass("sub-open2");
                      });
                  },
                  StickyNav: function () {
                      var navPos = $(".leftNav").offset()
                      var posTop = navPos.top - 80;
                      var posLeft = navPos.left;

                      $(window).scroll( function () {
                        if($(window).scrollTop() >= posTop){
                          $(".leftNav").css({"position":"fixed", "left":"0px", "margin-left":"90px", "top":"70px"});
                        }else {
                          $(".leftNav").css({"position":"", "left":"", "margin-left":"", "top":""});
                        }
                      });
                  },
                  HashListener: function () {
                      $(window).on("hashchange", leftNav.GetHash);
                  },
                  InitStatus: function () {
                      $linkItem.each(function () { 
                          $(this).attr("data-status","hidden") 
                      });
                  },
                  GetHash: function () {
                      var hash = window.location.hash;
                      var newHash = hash.replace("#","");
                      if(window.location.hash){
                        $(".page-include").hide();
                        $("."+newHash+"").show();
                      }

                      // $.ajax({
                      //   cache: "false",
                      //   url: "/apex/"+newHash+"",
                      //   contentType: "text/html; charset=utf-8",
                      //   crossDomain: true,
                      //   type: "GET",
                      //   context: document.body,
                      //   success: function(data) {
                      //     var loadData = $(data).each( function (index, value) {
                      //       if($(this).is("body")){
                      //         console.log($(this));
                      //       }  
                      //     });
                      //     $(".tab-pane").html(data);
                      //   }
                      // });
                      
                      $(".sub_content").css({"display":"none"});
                      $("[data-page='"+newHash+"']").addClass("active").siblings().removeClass("active"); 
                       if( typeof( $(".leftNav .active").attr('data-sub') ) == 'undefined' ) { 
                          if( $(".leftNav .active").length > 1 ){
                            $(".leftNav-sub").slideUp(300);
                            $("li[data-sub]").attr("data-status","hidden");
                            $(".sub-open2").removeClass("sub-open2");
                          }
                          
                          // alert($(".leftNav .active").attr('data-sub'));
                          // $(".leftNav-sub li").removeClass("active");
                        }

                      leftNav.Open( null, null, $(".leftNav-sub [data-page='"+newHash+"']").parents(".leftNav-sub") ); 
                      // leftNav.CloseAll( null, $(".leftNav-sub [data-page='"+newHash+"']").parents(".leftNav-sub").siblings(".leftNav-sub") );
                      // leftNav.Close( $(".leftNav-sub [data-page='"+newHash+"']").parents(".leftNav-sub"), $(".leftNav-sub [data-page='"+newHash+"']").parents(".leftNav-sub").prev("li")  );
                  },
                  CheckNavStatus: function ( $me ) {
                      var status     = $me.attr( "data-status" );
                      var dataSub    = $me.attr( "data-sub" );

                      if ( status == "hidden" ) { leftNav.Open( dataSub, $me, null ); }  
                      else if ( status == "visible" ) { 
                          if (dataSub){
                              leftNav.Close( dataSub, $me ) 
                          }
                          if (!dataSub){
                              leftNav.Close( null, $me )  
                          }
                      }
                  },
                  ScrollContTop: function () {
                      var navPos = $(".tab-pane").offset()
                      var posTop = navPos.top - 80;
                      $("html, body").animate({
                        scrollTop: posTop
                      }, 500);
                  },
                  Open: function ( dataSub, $me, extDataSub ) {
                      var $extDataSub         = extDataSub;
                      if (extDataSub == null) {
                          console.log("Open without extended data");
                          $("#"+dataSub+"").slideDown(300).addClass("sub-open2");   
                          $(".mainlinks li.active").removeClass("active");
                          $me.attr("data-status","visible");
                      }
                      if (extDataSub != null) {
                          console.log("Open with extended data");
                          $extDataSub.prev("li").attr("data-status", "visible");
                          $extDataSub.prev("li").siblings("li").removeClass("active");
                          $extDataSub.slideDown(300);
                          $extDataSub.prev("li").addClass("sub-open2");
                      }
                  },
                  Close: function ( dataSub, $me ) {
                      if (dataSub == null) {
                          $("#"+dataSub+"").slideUp(300);
                          dataSub.slideUp(300);
                          console.log($me);
                          console.log(dataSub);
                      }
                      $me.attr("data-status","hidden");
                  },
                  CloseAll: function ( $me, extDataSub ){
                      if ($me) {
                          var dataSub       = $me.attr( "data-sub" );
                      }
                      if (extDataSub == null) {
                          console.log("Close without extended data");
                          $(".leftNav-sub").not("#"+dataSub+"").slideUp(300);
                          // $(".leftNav-sub li").removeClass("active");
                          $me.siblings("li").attr("data-status","hidden");
                          $(".sub-open2").removeClass("sub-open2");
                      }
                      if (extDataSub != null) {
                        console.log("Close with extended data");
                          var $extDataSub       = extDataSub;
                          $extDataSub.slideUp(300);
                      }
                      if(!dataSub || dataSub != dataSub) {
                          // $(".leftNav li").removeClass("active-without-sub");
                      }
                  }
              };
              leftNav.Init(); 
          })() 
        });