# -*- encoding : utf-8 -*-

require 'oauth_doorman'
require 'oauth_doorman/sinatra'
require 'digest/sha1'

class NotesSinatra < Sinatra::Base
  register Sinatra::DoormanAuth
  
  DOORMAN_CONFIG = YAML.load_file('config/doorman_token.yml').symbolize_keys

  set :session_secret, Digest::SHA1.hexdigest("AtaxoVyvojAppliaction")
  
  #set oauth settings
  set :doorman_client_id, DOORMAN_CONFIG[:client_id]
  set :doorman_client_secret, DOORMAN_CONFIG[:client_secret]
  set :doorman_app_name, DOORMAN_CONFIG[:app_name]

  #set urls where to redirect after sign in/out
  set :default_url_after_sign_in, "/"
  set :default_url_after_sign_out, "/login"

  def self.request_ip_address= ip
    @request_ip_address = ip
  end

  def self.request_ip_address
    @request_ip_address
  end

  before do
    #autoload configuration of accesses from YAML
    Auth.load
  end

  module AuthHelpers
    #ovewrite protected from oauth doorman!
    def protected
      if session[:email]
        @api_access = Auth.get_by_name(session[:email])
      else
        redirect :login
      end
    end

    def protected_admin
      #call protected first
      protected
      
      #only accesses from ataxo domain are Admins!
      halt 403, erb(:forbidden) unless @api_access.admin?
    end

    def protected_api path
      token = request.env['HTTP_API_TOKEN'] || params['api_token'] || nil

      #let us know which url is making request
      self.class.request_ip_address = request.env['REMOTE_ADDR']

      # without token
      render_error 401, ApiError::Unauthorized, "You need to add api_token to your request." if token.nil?

      # unknown token
      unless Auth.application? token
        render_error 401, ApiError::Unauthorized, "Your token: '#{token}' is unknown or invalid. Please try fix your token or contact devpm@ataxo.com"
      end

      #get access from store
      @api_access = Auth.applications[token]

      unless @api_access.taxonomy?(@taxonomy)
        render_error 403, ApiError::Forbidden, "Your token: '#{token}' is not allowed to access taxonomy: #{@taxonomy}. If you think, you should be allowed to access this taxonomy, contact devpm@ataxo.com"
      end

      # disallowed method
      unless @api_access.method?(path)
        render_error 403, ApiError::Forbidden, "Your token: '#{token}' is not allowed to access api method: #{request.path}. If you think, you should be allowed to access this api method, contact devpm@ataxo.com"
      end
    end
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    #is there any Auth access for this token?
    if Auth.application? params[:api_token]
      @api_access = Auth.applications[params[:api_token]]
      session[:email] = @api_access.name
      redirect options.default_url_after_sign_in
    end
    @flash_error = "Invalid API_TOKEN"
    erb :login 
  end

  #include auth helpers!
  helpers AuthHelpers

  def authorize_user email
    valid_groups = true
    unless session[:email]
      groups_api = doorman
      groups_api.init_connection_by_refresh_token(DOORMAN_CONFIG[:provisioning_refresh_token])
      groups = groups_api.get_user_groups("ataxo.com", email)
      valid_groups = groups.include?("vyvoj@ataxo.com")
    end

    if valid_groups
      # if access doesn't exists - create one with default access only to sandbox!
      unless @api_access = Auth.get_by_name(email)
        @api_access = Auth.new( name: email, taxonomies: [:sandbox], methods: :all)
        #automatically backup new access
        Auth.save
      end
      true
    else
      nil
    end
  end

  get '/signed_out' do
    "You are signed out from Slim Api, <br /><a href='/'>Sign in</a>"
  end

  get "/accesses" do 
    protected_admin
    erb :accesses
  end

  post "/accesses/revoke_token" do
    protected_admin
    json_params =  Yajl::Parser.parse(request.body)
    token = Auth.applications[json_params['api_token']].generate_token
    Auth.save
    render_output api_token: token
  end

  get "/accesses/form" do 
    protected_admin
    @access =  Auth.applications[params['api_token']] if params['api_token']
    erb :accesses_form
  end

  post "/accesses" do
    protected_admin
    json_params =  Yajl::Parser.parse(request.body)
    #create new APP
    Auth.new(json_params)
    #save APP to backup YAML
    Auth.save
    
    render_output message: "Access was succesfully created"
  end

  put "/accesses" do
    protected_admin
    json_params =  Yajl::Parser.parse(request.body)
    #create new APP
    Auth.new(json_params)
    #save APP to backup YAML
    Auth.save
    
    render_output message: "Access was succesfully updated"
  end

  delete "/accesses/:api_key" do |api_key|
    if Auth.application? api_key
      Auth.remove api_key
      #save APP to backup YAML
      Auth.save
      render_output message: "Access was succesfully deleted" 
    else
      render_error 400, ApiError::NotFound, "Couldn't find any Access by given #{api_key} api key"
    end
  end

end