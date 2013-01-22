$(function() {
  
  $('.form_loader').hide();
  $('.fullscreen_start').hide();
  $.fn.serializeObject = function()
  {
      var o = {};
      var a = this.serializeArray();
      $.each(a, function() {
          if (o[this.name] !== undefined) {
              if (!o[this.name].push) {
                  o[this.name] = [o[this.name]];
              }
              if(this.value) {
                o[this.name].push(this.value);
              }
          } else {
              if(this.value) {
                o[this.name] = this.value;
              }
          }
      });
      return o;
  };          

  ajax_form = function(event, form, method) {
    var loader = $(form).closest('.method').find('.form_loader');
    var response = $(form).closest('.method').find('.form_response');
    $(response).html('');
    $(loader).show();
    console.log(JSON.stringify($(form).serializeObject()));
    $.ajax({
        url: $(form).attr('action'),
        type: method,
        headers: { 'Api-Token': $(form).attr('data-api-token') },
        contentType: "application/json",
        data: JSON.stringify($(form).serializeObject()),
        success: function (data, textStatus, jqXHR) {
          $(response).html('<div class="notify success">'+data["message"]+'</div>');
          $(loader).hide();
        },
        error: function (jqXHR, textStatus, errorThrown) {
          $(response).html('<div class="notify error"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
          $(loader).hide();
        }
    });

    return false;
  }

  $("form[method='delete']").bind("submit", function(evt) {
    return ajax_form(evt, this, "DELETE");
  });

  $("form[method='put']").bind("submit", function(evt) {
    return ajax_form(evt, this, "PUT");
  });

  $("form[method='post']").bind("submit", function(evt) {
    return ajax_form(evt, this, "POST");
  });

  $(document).keyup(function(e) {
    if (e.keyCode == 27) { 
      $('.overlay').hide();          
      $('.fullscreen').css('top', 0);
      $('.fullscreen').removeClass('fullscreen')
      $('.fullscreen_end').hide();
    }   // esc
  });

  function register_fullscreen(start, end) {
    $(start).show();
    $(end).hide();
    $(start).unbind('click');
    $(end).unbind('click');
    $(start).click(function(){
      $('.overlay').show();
      $('.overlay').css('height', $(document).height());
      $(start).closest('.method').find('.form_response').addClass('fullscreen');
      $(start).closest('.method').find('.form_response').css('top', window.pageYOffset+30);
      $(end).show();
      $(end).click(function(){
        $(start).closest('.method').find('.form_response').removeClass('fullscreen');
        $(start).closest('.method').find('.form_response').css('top', 0);
        $(end).hide();
        $('.overlay').hide();
      })
    })
  }

  $("form[method='get']").bind("submit", function(evt) {
    var loader = $(this).closest('.method').find('.form_loader');
    var response = $(this).closest('.method').find('.form_response');
    var fullscreen_start = $(this).closest('.method').find('.fullscreen_start');
    $(response).html('');
    $(loader).show();
    $(this).closest('.method').find('.form_response').html('<div class="fullscreen_end">END FULLSCREEEN</div><table class="grid_table display"></table>');
    var fullscreen_end = $(this).closest('.method').find('.fullscreen_end');
    $(fullscreen_end).hide();

    var table = $(this).closest('.method').find('.grid_table');
    var columnsNames = JSON.parse($(this).closest('.method').attr('data-columns'));
    var columnsHeaderNames = JSON.parse($(this).closest('.method').attr('data-header-columns'));
    var columnsModels = JSON.parse($(this).closest('.method').attr('data-columns-properties'));
    var model_name = $(this).closest('.method').attr('data-model');
    var models_name = $(this).closest('.method').attr('data-models');
    $(this).closest('.method').find('.grid_table').jqGrid({
      datatype: "local",
      colNames: columnsNames,
      colModel: columnsModels,
      viewrecords: true,
      sortorder: "desc",
      caption: "result",
      jsonReader: {
        repeatitems : false
      },
      height: '100%'
    });

    $.ajax({
      url: $(this).attr('action'),
      type: 'get',
      headers: { 'Api-Token': $(this).attr('data-api-token') },
      contentType: "application/json",
      data: $(this).serializeObject(),
      success: function (data, textStatus, jqXHR) {
        $(table).jqGrid('addRowData',1,columnsHeaderNames);
        if(data[models_name] != undefined) {
          for(var i=0;i<=data[models_name].length;i++)
            $(table).jqGrid('addRowData',i+2,data[models_name][i]);
        } else {
          $(table).jqGrid('addRowData',2,data[model_name]);
        }
        var data_table = $(table).closest('.form_response').find('.ui-jqgrid-btable');
        $(data_table).find('tr').eq(1).find('td').addClass('table_header');
        $(loader).hide();
        register_fullscreen(fullscreen_start, fullscreen_end);
      },
      error: function (jqXHR, textStatus, errorThrown) {
        $(response).html('<div class="notify error"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
        $(loader).hide();
      }
    });


    return false;
  });


  $(".with_tooltip").tooltip({

    // place tooltip on the right edge
    position: "center right",

    // a little tweaking of the position
    offset: [9, 20],

    // use the built-in fadeIn/fadeOut effect
    effect: "slide",

    // custom opacity setting
    opacity: 1

  });

  $('.url_params_update').keyup(function(){
    var method = $(this).closest('.method');
    var url = $(method).find('.url').attr('data-url');
    console.log(url);
    $(method).find('.url_params_update').each(function(){
      url = url.replace(':'+$(this).attr('data-param-name'), $(this).val());
    });
    $(method).find('form').attr('action', url);
    $(method).find('.url a').attr('href', url);
    $(method).find('.url a').text(url);
  });

  $('.update_form').click(function(){
    var form = $(this).closest('.method').find('form');
    var response = $(this).closest('.method').find('.form_response');
    var model_name = $(this).closest('.method').attr('data-model');
    var loader = $(this).closest('.method').find('.form_loader');
    var id = 0;
    if($(form).find('input[name="id"]').val().length == 0) {
      alert('Please fill ID and then you can continue');
      return false;
    } else {
      id = $(form).find('input[name="id"]').val();
    }
    $(loader).show();

    $.ajax({
      url: $(form).attr('action'),
      type: 'get',
      headers: { 'Api-Token': $(form).attr('data-api-token') },
      contentType: "application/json",
      data: {'id': id},
      success: function (data, textStatus, jqXHR) {
        for(var d in data[model_name]) {
          $(form).find("input[name='"+d+"']").val(data[model_name][d]);
          $(form).find("select[name='"+d+"']").find("option[value='"+data[model_name][d]+"']").attr('selected','selected');
        }
        $(loader).hide();
      },
      error: function (jqXHR, textStatus, errorThrown) {
        $(response).html('<div class="notify error"><pre>'+syntaxHighlight($.parseJSON(jqXHR.responseText)["message"])+'</pre></div>');
        $(loader).hide();
      }
    });

  })
});