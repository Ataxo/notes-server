# -*- encoding : utf-8 -*-

require 'digest/sha1'

class Auth

  attr_reader :name, :api_token, :taxonomies, :methods

  #add application to list
  def self.add auth
    #destroy old one
    if auth_old = get_by_name(auth.name)
      applications.delete(auth_old.api_token)
    end
    applications[auth.api_token] = auth
  end

  #remove application from list
  def self.remove api_token
    if application? api_token
      applications.delete(api_token)
    else
      nil
    end
  end

  def self.applications
    @applications ||= Hash.new({})
  end

  def self.application? token
    applications.has_key?(token)
  end

  def self.get_by_name name
    apps = applications.select{|key, auth| auth.name == name}
    apps.size == 1 ? apps.first.last : nil
  end

  def self.filename 
    File.join(APP_ROOT, "config", "application_access_#{ENV['RACK_ENV']}.yml")
  end

  def self.save backup_filename = filename
    data = @applications.inject({}) do |out, (token, auth)|
      out[auth.name] = {
        name: auth.name,
        api_token: auth.api_token,
        taxonomies: auth.taxonomies,
        methods: auth.methods,
      }
      out
    end
    File.open( backup_filename, 'w:UTF-8' ) do |fw|
      YAML.dump( data, fw )
    end
  end

  def self.load backup_filename = filename
    #clear previous settings
    @applications = {}
    #for backup - create file if it doesn't exists
    create_file(backup_filename) unless File.exists?(backup_filename)

    YAML.load(File.open(backup_filename, 'r:UTF-8').read).each do |app_name, app_data|
      new app_data
    end
  end

  def self.create_file backup_filename = filename
    File.open( backup_filename, 'w:UTF-8' ) do |fw|
      YAML.dump( {}, fw )
    end
  end

  def initialize args = {}
    args.symbolize_keys!
    raise ArgumentError, "Name is required!" if args[:name].blank?
    @name = args[:name]
    @api_token = args[:api_token] || generate_token || nil

    @taxonomies = args[:taxonomies]
    #fix casting of formular
    @taxonomies = @taxonomies.to_sym if @taxonomies.is_a?(String) 
    @taxonomies = [args[:taxonomies_specific]].flatten.collect{|t| t.to_sym } if @taxonomies == :specific

    @methods = args[:methods]
    #fix casting of formular
    @methods = @methods.to_sym if @methods.is_a?(String) 
    @methods = [args[:methods_specific]].flatten if @methods == :specific

    #add this app into application
    self.class.add self
  end

  def generate_token
    @api_token = Digest::SHA1.hexdigest "SlimApiToken-app:#{@name}:#{Date.today}:#{rand(0..100000)}"
  end

  def availible_taxonomies 
    if @taxonomies == :all
      Notes.taxonomies | [:sandbox]
    else
      @taxonomies | [:sandbox]
    end
  end

  def taxonomy? taxonomy
    #automatically return taxonomy sandbox as true
    return true if taxonomy.to_sym == :sandbox

    #if setting for taxonomies is ALL then return true
    return true if @taxonomies == :all

    #if settings contains taxonomy then return true
    @taxonomies.include?(taxonomy.to_sym)
  end

  def method? method
    #if setting for methods is ALL then return true
    return true if @methods == :all

    #if settings contains method then return true
    @methods.include?(method)
  end

  #only accesses with ataxo domain are admins!
  def admin?
    @name.include?("@ataxo.com")
  end

end