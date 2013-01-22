# -*- encoding : utf-8 -*-
require 'sinatra'
require 'sinatra/base'
require 'erb'
require 'yajl'


class NotesSinatra < Sinatra::Base
  # allow user to send normal get method with _method=put x delete
  use Rack::MethodOverride

  set :default_locale, 'en'

  set :views, File.dirname(__FILE__) + '/app_sinatra/views'

  TAXONOMY_URL_REGEXP = /^\/v\d+\/[a-z0-9_\-]+\//
  # Set connection based on TAXONOMY
  before do
    #path is api call
    if TAXONOMY_URL_REGEXP =~ request.path
      @api_call = true
      #split path for getting taxonomy
      path = request.path.split("/")
      set_taxonomy path[2] if path && path.size > 2 #taxonomy
    
    #by taxonomy param
    elsif params[:taxonomy]
      set_taxonomy params[:taxonomy]

    #by taxonomy session
    elsif session[:taxonomy]
      set_taxonomy session[:taxonomy]
      
    #set default as sandbox
    else
      set_taxonomy "sandbox"
    end
  end

  def set_taxonomy taxonomy
    @taxonomy = taxonomy
    session[:taxonomy] = taxonomy
    ApiAdapter::Note.index_name "notes_#{taxonomy}"
  rescue Exception => e
    render_error 500, e.class.to_s.demodulize, e.message
  end

end

#including Sinatra methods
Dir[File.join(File.dirname(__FILE__),"/app_sinatra/**/*.rb")].each {|file| require file }
