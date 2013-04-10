
Notes.taxonomies.each do |taxonomy|
  ApiAdapter::Note.index_name "notes_#{taxonomy}"
  unless ApiAdapter::Note.index.exists?
    puts "Creating Tire index for #{taxonomy}"
    ApiAdapter::Note.tire.create_elasticsearch_index
  end
end