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

  var getNext = function(sel){
    var next = sel.next();
    if(next.css('display') === "none") return getNext(next);
    return next;
  };

  var getPrev = function(sel){
    var prev = sel.prev();
    if(prev.css('display') === "none") return getPrev(prev);
    return prev;
  };

  //true: down, false: up
  var selectNext = function(direction){
    var sel = $('.navbar-nav').find(".active");
    var next = getNext(sel);
    var prev = getPrev(sel);
    if( direction && next.length > 0){
      next.trigger("click");
      return true;
    }
    if( !direction && prev.length > 0){
      prev.trigger("click");
      return true;
    }
    return false;
  };

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
