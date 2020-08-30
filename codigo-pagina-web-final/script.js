$(".console_col").click(function(){
  games_container = $("#"+this.id+"_games");
  /*console_logo = $(this).children(".console_logo");*/
  
  if (games_container.css("display") == "none"){
    games_container.css("display","block");
    
    $(this).addClass("col-xs-12");
    $(this).removeClass("col");

    /*console_logo.removeClass("cl_closed");
    console_logo.addClass("cl_open");*/

  } else {
    games_container.css("display","none");

    $(this).addClass("col");
    $(this).removeClass("col-xs-12");

    /*console_logo.removeClass("cl_open");
    console_logo.addClass("cl_closed");*/
  }
})