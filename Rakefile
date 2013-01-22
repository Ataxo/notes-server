# -*- encoding : utf-8 -*-
ENV['RACK_ENV'] ||= "development"
ENV['TAXONOMY'] ||= "sandbox"

require './notes_app'
require './notes_sinatra'
require 'rack/test'
require 'rake/testtask'


Dir["tasks/*.rake"].sort.each { |ext| load ext }

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/functional/**/*_test.rb', 'test/unit/**/*_test.rb','test/integration/**/*_test.rb']
  t.warning = false
  t.verbose = false
end

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList['test/unit/**/*.rb']
    t.warning = false
    t.verbose = false
  end

  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/functional/**/*.rb']
    t.warning = false
    t.verbose = false
  end

  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList['test/integration/**/*.rb']
    t.warning = false
    t.verbose = false
  end
end
