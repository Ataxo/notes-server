# -*- encoding : utf-8 -*-
ENV['RACK_ENV'] = "test"

require 'simplecov'
SimpleCov.start do 
  add_filter "/test/"
  add_filter "/config/"

  add_group 'Sinatra', 'app_sinatra'
  add_group 'Unit', 'app/'
  add_group 'Lib', 'lib/'
end

require 'rack/test'
require 'test/unit'
require "mocha/setup"
require './notes_app'
require './notes_sinatra'
require 'turn'
require 'shoulda-context'

require './test/models'

require 'bundler'
Bundler.setup

ApiAdapter::Note.index_name "test_sandbox"