# -*- encoding : utf-8 -*-
require 'cpu-memory-stats'

class NotesSinatra < Sinatra::Base
  
  def get_link name, type = :normal
    "<li><a href='/#{name}' class='#{ "active" if request.env['PATH_INFO'] == "/#{name}" } link_type_#{type}' >#{name.upcase}</a></li>"
  end

  get '/is_alive' do
    render_output :message => "Oh yeah Baby! Slim Api is alive :-)"
  end

  get '/' do
    protected
    redirect :home
  end

  get '/home' do
    protected
    erb :index
  end

  get '/doc/:version' do |version|
    protected
    @version = version.to_sym
    erb :documentation
  end

  get '/change_log' do
    protected
    erb :change_log
  end
  
  get '/change_log.json' do
    render_output :changelog => {:version => APP_VERSION_GIT.version, :logs => APP_VERSION_GIT.changelog}
  end

  get '/system_stats.json' do
    render_output :stats => CpuMemoryStats.get
  end
  
end
