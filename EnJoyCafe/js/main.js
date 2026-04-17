/* ================================================================
   main.js  —  EnJoyCafe general UI helpers
 ================================================================ */
$(function() {

  /* Auto-dismiss alerts */
  setTimeout(function(){ $('.alert').fadeOut(500); }, 4000);

  /* Back-to-top button */
  var $btt = $('<button title="Back to top" style="position:fixed;bottom:26px;right:26px;width:42px;height:42px;background:var(--copper);color:#fff;border:none;border-radius:50%;font-size:.9rem;cursor:pointer;display:none;align-items:center;justify-content:center;box-shadow:0 4px 14px rgba(0,0,0,.2);z-index:999;transition:.3s;"><i class=\'fas fa-chevron-up\'></i></button>').appendTo('body');
  $(window).on('scroll', function(){ $(this).scrollTop()>280 ? $btt.css('display','flex') : $btt.hide(); });
  $btt.on('click', function(){ $('html,body').animate({scrollTop:0},450); });

  /* Smooth anchor scroll */
  $(document).on('click','a[href^="#"]',function(e){
    var t = $($(this).attr('href'));
    if(t.length){ e.preventDefault(); $('html,body').animate({scrollTop:t.offset().top-76},550); }
  });

  /* Confirm delete */
  $(document).on('click','.confirm-del',function(e){
    if(!confirm('Are you sure? This cannot be undone.')) e.preventDefault();
  });

});
