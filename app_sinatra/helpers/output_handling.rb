# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  #disable default exception html response - use instead JSON Response
  set :show_exceptions, false

  #Resquing from Exceptions by wrapping exceptions to JSON output
  error do
    content_type :json
    
    #Change error code based on Exception class
    error_code = 500
    error_code = 400 if env["sinatra.error"].class == ApiError::BadRequest
    error_code = 400 if env["sinatra.error"].class == ApiError::NotFound
    error_code = 401 if env["sinatra.error"].class == ApiError::Unauthorized
    error_code = 403 if env["sinatra.error"].class == ApiError::Forbidden
    
    #compose output JSON
    output = {
      :status => "error", 
      :code => error_code, 
      :error_type => env["sinatra.error"].class.to_s, 
      :message => env["sinatra.error"].message, 
      :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
    #warning about conent type!
    output[:warning_invalid_content_type] = "Please set request header content-type to 'application/json' - if you will not se it you are limited by 64KB by request" unless request.env['CONTENT_TYPE'] && request.env['CONTENT_TYPE'].include?("application/json")
    puts env["sinatra.error"].backtrace
    #allow to show backtrace on development and test environment
    output[:backtrace] = env["sinatra.error"].backtrace if ["test", "development", "stage"].include?(ENV['RACK_ENV'])
    halt error_code, Yajl::Encoder.encode(output)
  end

  # handle not found error response
  not_found do
    render_error 404, ApiError::RouteNotFound, "Slim Api doesn't know this route: #{request.path}, Please look into documentation http://#{request.host}/"
  end

  #Method for generating standart looking output
  def render_error error_code, error_type, text
    content_type :json

    #compose output JSON
    output = { 
      :status => "error", 
      :code => error_code.to_i, 
      :error_type => error_type.to_s, 
      :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"), 
    }

    if text.is_a?(Hash)
      output.merge!(text)
    else
      output[:message] = text 
    end

    #warning about conent type!
    output[:warning_invalid_content_type] = "Please set request header content-type to 'application/json' - if you will not se it you are limited by 64KB by request" unless request.env['CONTENT_TYPE'] && request.env['CONTENT_TYPE'].include?("application/json")

    #items and name specified
    halt error_code.to_i, Yajl::Encoder.encode(output)
  end

  #Method for generating standart looking output
  def render_output item = nil, code = 200
    content_type :json

    #compose output JSON
    output = {:status => "ok", :code => code, :message => "ok", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"), :executed_in => "#{Time.now - self.benchmark}s"}

    #warning about conent type!
    output[:warning_invalid_content_type] = "Please set request header content-type to 'application/json' - if you will not se it you are limited by 64KB by request" unless request.env['CONTENT_TYPE'] && request.env['CONTENT_TYPE'].include?("application/json")

    #return JSON output + item or only output
    halt code, Yajl::Encoder.encode( item ? output.merge(item) : output )
  end
end