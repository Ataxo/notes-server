# -*- encoding : utf-8 -*-

env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'production'

if env == "stage"
  worker_processes 2
elsif env == "production"
  worker_processes 5
else
  worker_processes 1
end
# Load rails+project into the master before forking workers
# for super-fast worker spawn times
# leave it "false" when you have telnet-like connection to db (redis, mongo)
preload_app true

#Use unicorn to prefere Fork over Thread.new
Rainbows! do
  use :Unicorn
  client_max_body_size nil
end

# Restart any workers that haven't responded in timeout
timeout 10*60 #10 minutes

# Listen on a Unix data socket
FileUtils.mkdir_p(File.join(File.dirname(__FILE__),"..","/tmp/sockets").to_s) unless File.exists?(File.join(File.dirname(__FILE__),"..","/tmp/sockets"))
listen File.expand_path(File.join(File.dirname(__FILE__),"..","/tmp/sockets/rainbows.sock")), :backlog => 2048

# PID file
FileUtils.mkdir_p(File.join(File.dirname(__FILE__),"..","/tmp/pids").to_s) unless File.exists?(File.join(File.dirname(__FILE__),"..","/tmp/pids"))
pid File.expand_path File.join(File.dirname(__FILE__),"..","/tmp/pids/rainbows.pid")

# some applications/frameworks log to stderr or stdout, so prevent
# them from going to /dev/null when daemonized here:
FileUtils.mkdir_p(File.join(File.dirname(__FILE__),"..","/log").to_s) unless File.exists?(File.join(File.dirname(__FILE__),"..","/log"))
stderr_path File.join(File.dirname(__FILE__),"..","/log/rainbows_stderr_#{env}.log")
stdout_path File.join(File.dirname(__FILE__),"..","/log/rainbows_stdout_#{env}.log")

