/* ================================================================
   admin.js  —  EnJoyCafe admin panel JS
 ================================================================ */
$(function() {

  /* Sidebar toggle (mobile) */
  $(document).on('click','#sidebarToggle, .sidebar-toggle',function(){
    $('#sidebar').toggleClass('open');
  });

  /* Auto-dismiss alerts */
  setTimeout(function(){ $('.alert').fadeOut(500); }, 4000);

  /* Confirm delete */
  $(document).on('click','.confirm-del',function(e){
    if(!confirm('Are you sure? This cannot be undone.')) e.preventDefault();
  });

  /* Table search */
  $(document).on('input','.tbl-search',function(){
    var q = $(this).val().toLowerCase();
    var $rows = $($(this).data('tbl') || 'table').find('tbody tr');
    $rows.each(function(){ $(this).toggle(!q || $(this).text().toLowerCase().indexOf(q) > -1); });
  });

  /* Image URL live preview */
  $(document).on('change blur','input[name="image_url"],input[name="photo_url"]',function(){
    var url = $(this).val().trim();
    var $p  = $(this).closest('.form-group').find('.img-preview');
    if (!$p.length) {
      $p = $('<img class="img-preview" style="margin-top:8px;max-width:130px;height:85px;object-fit:cover;border-radius:8px;border:1px solid var(--cream2);">');
      $(this).closest('.form-group').append($p);
    }
    url ? $p.attr('src', url).show() : $p.hide();
  });
  $('input[name="image_url"],input[name="photo_url"]').each(function(){
    if($(this).val()) $(this).trigger('blur');
  });

  /* Card number formatter */
  $(document).on('input','#cardNum',function(){
    var v = $(this).val().replace(/\D/g,'').substring(0,16);
    $(this).val(v.replace(/(.{4})/g,'$1 ').trim());
  });
  $(document).on('input','#cardExpiry',function(){
    var v = $(this).val().replace(/\D/g,'').substring(0,4);
    if(v.length>2) v = v.substring(0,2)+'/'+v.substring(2);
    $(this).val(v);
  });

});
