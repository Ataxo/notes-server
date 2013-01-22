$(function() {
  
  $('.taxonomy_selection').change(function(){
    window.location.href = window.location.href.split("?")[0] + '?taxonomy='+$(this).find('option:selected').val();
  });

})