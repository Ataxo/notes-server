# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  #get form
  get "/form/:version" do |version|
    protected
    @version = version.to_sym
    erb :v1_form
  end

end