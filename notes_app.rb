# -*- encoding : utf-8 -*-
require 'rubygems'
require 'rack'
require 'pp'
require 'logger'
require 'tire'
require 'tire/http/clients/curb'
require 'digest/sha1'

require 'copycopter_client'

Tire.configure do
  client Tire::HTTP::Client::Curb
end

APP_ROOT = File.expand_path(File.dirname(__FILE__))

Encoding.default_internal = Encoding.default_external = "UTF-8"

require 'app-version-git'
APP_VERSION_GIT = AppVersion.new(__FILE__)

ENV['RACK_ENV'] ||= "development"
ENV['RAILS_ENV'] ||= ENV['RACK_ENV']

#including lib
Dir[File.join(File.dirname(__FILE__),"/lib/*.rb")].each {|file| require file }

#including main classes
Dir[File.join(File.dirname(__FILE__),"/app/**/*.rb")].each {|file| require file }

require './config/initializer'

require './config/notes_taxonomies' if File.exist?("./config/notes_taxonomies.rb")
