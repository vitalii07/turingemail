/******************
*** Benefits JS ***
******************/

$(function() {
  $('#benefit-modernize img').load(function() {
    $('.benefit-modernize').addClass('appear');
  });
  $('.mobile_hamburger').on('click', function() {
    var $this = $(this).parent().find('.nav-menu');
    if($this.hasClass('open')) {
      $this.removeClass('open');
      $('.header .mobile').removeClass('open');
    }
    else {
      $this.addClass('open');
      $('.header .mobile').addClass('open');
    }
  });
});

$(function () {
  $("body.benefits").append('<div class="benefits-mobile"><div class="benefits-slide"><p>Benefits</p><div class="benefits-nav"><a class="arrows left-arrow">&lsaquo;</a><a class="arrows right-arrow">&rsaquo;</a></div></div></div>');
  i = 0;
  $("body.benefits section.benefit").each(function(){
    thisid = $(this).attr("id");
    i++;
  if(i != 7){
    if(i == 1){
      $(this).addClass("active");
      $(".benefits-nav").append('<a class="benefits active bullet-nav" id="nav-'+thisid+'" href="#'+thisid+'"></a>');
      }else{
        $(this).addClass("slide-left");
      $(".benefits-nav").append('<a class="benefits bullet-nav" id="nav-'+thisid+'" href="#'+thisid+'"></a>');
      }
  }else{
    $(this).removeClass("benefit");
    $(".benefits-mobile").css("top", $(".benefit-modernize").height()+140);
  }
  });
  $("body.benefits .right-arrow").click(function(){
  if($(".benefit.active").nextAll(".benefit").length){
    $(".benefit.active").removeClass("active").addClass("slide-right").next(".benefit").addClass("active").removeClass("slide-right").removeClass("slide-left");
    $(".bullet-nav.active").removeClass("active").next(".bullet-nav").addClass("active");
  }else{
     window.location.href = "/features";
  }
  });
  $("body.benefits .left-arrow").click(function(){
  if($(".benefit.active").prevAll(".benefit").length){
    $(".benefit.active").removeClass("active").addClass("slide-left").prev(".benefit").addClass("active").removeClass("slide-right").removeClass("slide-left");
    $(".bullet-nav.active").removeClass("active").prev(".bullet-nav").addClass("active");
  }else{
     window.location.href = "/";
  }
  });
  $("body.benefits .bullet-nav").click(function(event){
    event.preventDefault();
    thisbenefit = $(this).attr('href');
  if($(thisbenefit).prevAll(".benefit.active").length){
    $(".benefit.active").removeClass("active").addClass("slide-right");
    $(thisbenefit).addClass("active").removeClass("slide-right").removeClass("slide-left");
  }else{
    $(".benefit.active").removeClass("active").addClass("slide-left");
    $(thisbenefit).addClass("active").removeClass("slide-right").removeClass("slide-left");
  }
  $(".bullet-nav").removeClass("active");
  $(this).addClass("active");
  });
});

/******************
*** Features JS ***
******************/

$(function () {
  $(".feature-tabs").addClass("tabs-loaded");
  $(".feature-view").removeClass("active");
  $(".feature-tabs").css('height', $(".features #tab-1").height());
  $("body.features .content").append('<div class="feature-mobile"><a class="button button-big button-main" href="/pricing">Select the <strong>Individual Plan</strong></a><div class="feature-slide"><p>Feature Collections</p><div class="feature-nav"><a class="arrows left-arrow disabled">&lsaquo;</a><a class="arrows right-arrow">&rsaquo;</a></div></div></div>');
  $(".feature-view").each(function(){
    thisid = $(this).attr("id");
  $(".feature-nav").append('<a data-toggle="tab" class="'+thisid+' bullet-nav" id="nav-'+thisid+'" href="#'+thisid+'"></a>');
  });
  $(".feature-tabs a").each(function(){
  thishref = $(this).attr("href");
  thisid = thishref.replace(/\#/g, '');
  $(this).addClass(thisid);
  });
  $(".features #tab-1").addClass("active");
  $(".features #nav-tab-1").addClass("active");
  $(".feature-nav a.bullet-nav").click(function(){
  selectedtab = $(this).attr('href');
  selecttab = selectedtab.replace(/\#/g, '');
  $(".content > .button").html($(selectedtab+" .button").html());
  $(".feature-view").removeClass("active");
  $(".feature-nav a").removeClass("active");
  $(".feature-tabs li").removeClass("active");
  $(".feature-tabs ."+selecttab).parent("li").addClass("active");
  $(".feature-nav ."+selecttab).addClass("active");
  if(selecttab == "tab-1"){
    $(".feature-mobile .left-arrow").addClass("disabled");
  }else{
    $(".feature-mobile .left-arrow").removeClass("disabled");
  };
  });
  $(".feature-tabs a").click(function(){
  selectedtab = $(this).attr('href');
  selecttab = selectedtab.replace(/\#/g, '');
  $(".content > .button").html($(selectedtab+" .button").html());
  $(".feature-nav a").removeClass("active");
  $("."+selecttab).addClass("active");
  if(selecttab == "tab-1"){
    $(".feature-mobile .left-arrow").addClass("disabled");
  }else{
    $(".feature-mobile .left-arrow").removeClass("disabled");
  };;
  });
  $(".feature-mobile .left-arrow").click(function(){
    if($(".feature-view.active").prev().is(".feature-view")){
      $(".feature-view.active").removeClass("active").prev(".feature-view").addClass("active");
      $(".feature-nav a.bullet-nav.active").removeClass("active").prev(".feature-nav a.bullet-nav").addClass("active");
      $(".feature-tabs li.active").removeClass("active").prev(".feature-tabs li").addClass("active");
      if($(".feature-view.active").prev().is(".feature-view")){
      $(".feature-mobile .left-arrow").removeClass("disabled");
    }else{
    $(".feature-mobile .left-arrow").addClass("disabled");
    };
    };
  });
  $(".feature-mobile .right-arrow").click(function(){
    if($(".feature-view.active").next().is(".feature-view")){
      $(".feature-view.active").removeClass("active").next(".feature-view").addClass("active");
      $(".feature-nav a.bullet-nav.active").removeClass("active").next(".feature-nav a.bullet-nav").addClass("active");
      $(".feature-tabs li.active").removeClass("active").next(".feature-tabs li").addClass("active");
      if($(".feature-view.active").prev().is(".feature-view")){
      $(".feature-mobile .left-arrow").removeClass("disabled");
    }else{
    $(".feature-mobile .left-arrow").addClass("disabled");
    };
    }else{
      window.location.href = "/pricing";
    };
  });
});

/**************************
*** Waitlist/Confirm JS ***
**************************/

$(function () {
  $("body.waitlist").append('<div class="waitlist-mobile"><div class="waitlist-slide"><span>Join Now</span><a class="arrows left-arrow disabled">&lsaquo;</a><a href="/benefits" class="arrows right-arrow">&rsaquo;</a></div></div>');
  $("body.confirm").append('<div class="waitlist-mobile"><a class="button button-big button-main" href="/demo"><strong>Live</strong> Demo</a><a class="button button-big button-main" href="/benefits">Turing <strong>Features</strong></a><div class="waitlist-slide"><span>Join Now</span><a class="arrows left-arrow disabled">&lsaquo;</a><a href="/benefits" class="arrows right-arrow">&rsaquo;</a></div></div>');
});

window.onload = function () {

  return $("ul.waitlist li").on('click', function() {
    // store types
    clickedType = $(this).data('type');
    currentType = $(".collection-dropdown .dropdown-button b").text()

    // swap types
    $(".collection-dropdown .dropdown-button b").text(clickedType)
    $(this).data('type', currentType)
    $(this).find("a").text(currentType + " Collection")

    return $('#waitlist_user_collection_type').val(clickedType);
  });
};

/**************
*** Demo JS ***
**************/

$(function() {
  $(".demo-video_play").click(function() {
    $(".demo-video").css("background-image", "url(/images/landing/demo-macbook_mask.png)");
    $(".demo-video_placeholder").html('<iframe src="https://www.youtube.com/embed/ySZbvnQTWco?autoplay=1&loop=1&showinfo=0&rel=0&wmode=transparent&controls=0" frameborder="0" width="860" height="645" allowfullscreen wmode="Opaque"></iframe>');
    $(".demo-video_play").hide();
  });
});

/*****************
*** Pricing JS ***
*****************/

$(function () {
  $("body.pricing").append('<div class="pricing-mobile"><div class="pricing-slide"><span>Pricing</span><a class="arrows left-arrow disabled">&lsaquo;</a><a href="/users/sign_up" class="arrows right-arrow">&rsaquo;</a></div></div>');
  referrer = /[^/]*$/.exec(document.referrer)[0];;
  if(referrer == 'collections'){
	$("body.pricing .pricing-column:first-child").addClass("highlight");
  }
  $("body.pricing .pricing-column").append('<a class="price-mobile" href="/users/sign_up"></a>');
});

/*****************
*** Sign up JS ***
*****************/

$(function () {
  $("#user_email, #user_password", "body.signup").on("keyup", function() {
    $input = $(this);
    $input.siblings(".signup-form_field-note").toggle($input.val() === '');
  });

  if($("#user_email").val() != ""){
    $("#user_email").siblings(".signup-form_field-note").hide();
  }

  $("body.signup").append('<div class="signup-mobile"><div class="signup-slide"><p>Join Now</p><span class="bullet-nav"><span class="active"></span> <span></span> <span></span></span><a class="arrows left-arrow disabled">&lsaquo;</a><a href="#" onclick="$(\'form\').submit();" class="arrows right-arrow">&rsaquo;</a></div></div>');
  $("body.signup .signup-columns_sidecol").addClass("signup-load");
  $("body.signup .signup-columns_sidecol").append('<a class="sign-mobile" href="/pricing"></a>');
  signupnotice = $(".signup-form_notice_1").html();
  if(signupnotice != undefined){
  	$("body.signup .signup-columns_maincol").append('<p class="signup-form_notice mobilenotice">'+signupnotice+'<p>');
  };
  $("body.signup form.payment").prev("h1").addClass("payment_title");
  if($("body.signup form").hasClass("payment")){
  	$(".bullet-nav").addClass("steptwo");
  	$('.signup-form_fieldset>.signup-form_field>input.input-big').payment('formatCardNumber');
  };
  if($("body.signup .signup-columns_maincol>div").hasClass("signup-accounts")){
  	$(".bullet-nav").addClass("stepthree");
  	$("body").addClass("stepthree");
  	$(".right-arrow").attr("href", "/take_me_to_turing");
  	$(".right-arrow").attr("onclick", "");
  	signuphtml = $(".signup-accounts_notice").html();
  	if(signuphtml != undefined){
  	  $("body.signup .signup-columns_maincol").append('<p class="signup-accounts_notice mobilenotice">'+signuphtml+'</p>');
  	};
  	if($("body.signup .signup-columns_maincol .signup-accounts>div").hasClass("signup-account")){
	  $(".mobilenotice").hide();
	  $(".signup-step").hide();
	  $(".signup-accounts_notice").hide();
	  $("body.signup h1").text("Add another account.");
  	};
  };
});

/*****************
*** Landing JS ***
*****************/

$(window).load(function () {
  $('.carousel').carousel();
});

//window.onload = function () {
//   // Need to test it in production
//   var i = 0,
//       max = 0,
//       o = null,

//       // list of stuff to preload
//       preload = [
//           window.applicationJsUrl,
//           window.applicationCssUrl
//       ],
//       isIE = navigator.appName.indexOf('Microsoft') === 0;

//   for (i = 0, max = preload.length; i < max; i += 1) {
//     if (isIE) {
//         new Image().src = preload[i];
//         continue;
//     }
//     o = document.createElement('object');
//     o.data = preload[i];

//     // IE stuff, otherwise 0x0 is OK
//     //o.width = 1;
//     //o.height = 1;
//     //o.style.visibility = "hidden";
//     //o.type = "text/plain"; // IE
//     o.width  = 0;
//     o.height = 0;
//     o.style.position = 'absolute';

//     // only FF appends to the head
//     // all others require body
//     document.body.appendChild(o);
//   }
//};