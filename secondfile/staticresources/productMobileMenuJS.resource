$(document).ready(function(){
            
  //Controls Dropdown Functionality
  $(".dropdown-label").click(function(){
      var myStatus = $(".dropdown-label").attr("data-status");
      if(myStatus == "closed"){
          $(".mobile-dropdown-menu").css({"display":"block"});
          $(".dropdown-label").attr("data-status","open");
      }else if(myStatus == "open"){
          $(".mobile-dropdown-menu").css({"display":"none"});
          $(".dropdown-label").attr("data-status","closed");
      }
  });

  //Controls dropdown label based on .leftNav interaction
  $(".leftNav a").click(function(){
      var myText = $(this).text();
      $(".dropdown-label").text(myText);
  });

  //Controls dropdown menu selection events
  $(".mobile-dropdown-menu a").click(function(){
    var myHref = $(this).attr("data-page");
    var label = $(this).text();
    
    // Close dropdown menu
    $(".mobile-dropdown-menu").css({"display":"none"});
    $(".dropdown-label").attr("data-status","closed");
    
    /*Highlight this active link
    $(this).children("li").css({"background-color":"#f0f0f0"});
    $(this).siblings().children("li").css({"background-color":""});
    */
    
    //Highlight correct .leftNav link
    $(".leftNav a:contains("+label+")").parent().addClass("active").siblings().removeClass("active");
    
    // Show content
    $("#"+myHref+"").addClass("active").siblings().removeClass("active");
                  
    //Set Dropdown Label
    $(".dropdown-label").text(label);
    
    //Animate scroll to top
    $("body, html").animate({
        scrollTop: "360px"
    });
  });
});