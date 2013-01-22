$(function() {

  var accesses_loader = $('.acceses_loader');
  $(accesses_loader).hide();

  $('.allow_access').click(function(){
    var checkBoxes = $("input.method_type_"+$(this).attr('data-type'));
    checkBoxes.attr("checked", !checkBoxes.prop("checked"));
  })

  $('.revoke_token_access').click(function(){
    $(accesses_loader).show();
    var token = $(this).closest('.access_container').attr('data-token');
    var container = $('.access_container[data-token="'+token+'"]');
    var response = $('.accesses_response');
    $.ajax({
      url: "/accesses/revoke_token",
      type: 'post',
      contentType: "application/json",
      data: JSON.stringify({ api_token: token }),
      success: function (data, textStatus, jqXHR) {
        $(container).attr('data-token',data["api_token"]);
        $(container).find('.api_token').html(data["api_token"]);
        $(container).find('.update_access').attr('href', '/accesses/form?api_token='+data["api_token"]);
        $(response).html('<div class="notify success"><pre>Token was succesfully revoked to new one: <b>'+data["api_token"]+'</b></pre></div>');
        $(accesses_loader).hide();
      },
      error: function (jqXHR, textStatus, errorThrown) {
        $(response).html('<div class="notify error"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
        $(accesses_loader).hide();
      }
    });

  })

  function update_form_specific(obj, type) {
    var group = $(obj).closest('.group');
    if($(group).find('input[name='+type+']:checked').val() == "all") {
      group.find('.specific').hide();
    } else {
      group.find('.specific').show();
    }
  }

  $('input[name="taxonomies"]').change(function(){
    update_form_specific(this, "taxonomies");
  })

  $('input[name="methods"]').change(function(){
    update_form_specific(this, "methods");
  })

  //update first time when forms load
  update_form_specific('input[name="taxonomies"]', 'taxonomies');
  update_form_specific('input[name="methods"]', "methods");

  $('.remove_access').click(function(){
    var container = $(this).closest('.access_container');
    var response = $('.accesses_response');
    if (confirm("Are you sure you want to remove: "+$(container).find('.access_name').text())==true) {
      $.ajax({
        url: "/accesses/"+$(container).attr('data-token'),
        type: 'delete',
        contentType: "application/json",
        success: function (data, textStatus, jqXHR) {
          var apiToken = $(container).attr('data-token');
          $("tr[data-token='"+apiToken+"']").remove();          
          $(response).html('<div class="notify success"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
          $(accesses_loader).hide();
        },
        error: function (jqXHR, textStatus, errorThrown) {
          $(response).html('<div class="notify error"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
          $(accesses_loader).hide();
        }
      });
    }
  })
});