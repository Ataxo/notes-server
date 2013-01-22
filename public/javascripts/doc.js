$(function() {
  
  $('.response').hide();

  function build_response(type, url, token, input, data) {
    out = "<h4>Request Attributes</h4>"
    out += "<pre><code class='javascript'>"
    out += "// url\n"
    out += type+" "+url+"\n"
    out += "// headers\n"
    out += "Api-Token: "+token
    if(input != undefined) {
      out += "\n// request body:\n"
      out += JSON.stringify(JSON.parse(input),undefined, 2)
    }
    out += "</code></pre>"

    out += "<h4>Request by Curl</h4>"
    out += "<pre><code class='ruby'>"
    out += "curl --include \\\n"
    out += "     --request "+type.toUpperCase()+" \\\n"
    out += "     --header \"Api-Token:"+token+"\"  \\\n"
    if(input != undefined) {
      out += "     --data \'"+input+"\' \\\n"
    } else {
      out += "     --data \'\' \\\n"
    }
    out += "     \""+url+"\""
    out += "</code></pre>"

    out += "<h4>Response</h4>"
    out += "<pre><code class='javascript'>"+JSON.stringify(data,undefined, 2)+"</code></pre>"
    return out;
  }

  $('.type').click(function(){
    var method = $(this).closest('.method');
    var response = $(method).find('.response');
    var type = $(method).find('.type').text();
    var url = $(method).find('.url').text();
    var url_host = $(method).attr('data-url-host');
    var fixture = $(method).attr('data-fixture');
    if($(response).hasClass('not_initialized')) {
      if(type == "get") {
        // get fixture response
        $.ajax({
          type: type,
          dataType: 'JSON',
          data: {fixtures: true},
          headers: { 'Api-Token': $(method).attr('data-api-token') },
          url: url,
          success: function(data) {
            $(response).removeClass('not_initialized');
            $(response).html(build_response(type, url_host+url, $(method).attr('data-api-token'), undefined, data));
            $('pre code[class="javascript"]').each(function(i, e) {hljs.highlightBlock(e)});
          }
        });
      };
      if(type == "post") {
        $.ajax({
          type: type,
          dataType: 'JSON',
          data: fixture,
          headers: { 'Api-Token': $(method).attr('data-api-token') },
          url: url,
          success: function(data) {
            $(response).removeClass('not_initialized');
            $(response).html(build_response(type, url_host+url, $(method).attr('data-api-token'), fixture, data));
            $('pre code[class="javascript"]').each(function(i, e) {hljs.highlightBlock(e)});
          }
        });
      }
    }
    $(response).toggle();
  })

  $('pre code[class="javascript"]').each(function(i, e) {hljs.highlightBlock(e)});
  $('pre code[class="ruby"]').each(function(i, e) {hljs.highlightBlock(e)});

  $('.fast_navigation a').click(function(){
      $($(this).attr('href')).effect( 'highlight',{color:"#b1b1b1"}, 1000);
  });
})