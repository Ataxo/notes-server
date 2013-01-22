# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  # enable t & l helper in views for translations
  module I18nHelpers
    def l(what, options={})
      I18n.l what, {:locale => I18n.locale}.merge(options)
    end

    def t(what, options={})
      output = I18n.t what, {:locale => I18n.locale}.merge(options)
      output
    end

    def show_time time 
      time ? time.strftime("%Y-%m-%d %H:%M:%S") : "-"
    end
  end

  after do
    unless @api_call
      #Flush new blurbs only in development
      CopycopterClient.flush unless ENV['RACK_ENV'] == 'production' 
    end
  end

  #include translation helpers
  helpers I18nHelpers
end