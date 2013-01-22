# config.ru
require './notes_app.rb'
require './notes_sinatra.rb'

# Map applications
run Rack::URLMap.new \
  "/"       => NotesSinatra.new
