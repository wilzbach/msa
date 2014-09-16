jQuery(function($) {

  $(function(){
    $('#main-slider.carousel').carousel({
      interval: 9000,
      pause: false
    });
  });


  //smooth scroll
  blockScroller = false;
  $('.navbar-nav > li').click(function(event) {
    event.preventDefault();
    var target = $(this).find('>a').prop('hash');
    var navbar = $("#navbar").height();
    $('html, body').animate({
      scrollTop: $(target).offset().top - navbar + 1
    }, 500);
  });

  //scrollspy
  $('body').scrollspy({
    offset: $("#navbar").height()
  });


  //true: down, false: up
  var selectNext = function(direction){
    var sel = $('.navbar-nav').find(".active");
    if( direction && sel.next().length > 0){
      sel.next().trigger("click");
      return true;
    }
    if( !direction && sel.prev().length > 0){
      sel.prev().trigger("click");
      return true;
    }
    return false;
  }

  // pagging goes to the next selection
  $(window).keydown(function(e) {
    switch(e.keyCode){
      // pagedown
      case 34:
        if(selectNext(true)){
          e.stopPropagation();
          e.preventDefault();
        }
        break;
        // pageup
      case 33:
        if(selectNext(false)){
          e.stopPropagation();
          e.preventDefault();
        }
        break;
    }
  })
});
