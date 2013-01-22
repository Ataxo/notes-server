# -*- encoding : utf-8 -*-

I18n.default_locale = :en
I18n.locale = I18n.default_locale

#Set Copycopter server
CopycopterClient.configure(true) do |config|
  config.api_key = 'eeefebcade65c93061689c2602fdd9a41392d06a16733cc8'
  config.host = 'copycopter.ataxo.com'
  config.environment_name = "development"
  config.polling_delay = 60
end

I18n.backend = CopycopterClient::I18nBackend.new CopycopterClient.cache

#Enable Query Cache

