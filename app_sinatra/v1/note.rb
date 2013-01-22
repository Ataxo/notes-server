# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  ApiDoc::Method.new(
    :class_name => ApiAdapter::Note,
    :version => :v1,
    :url => "/notes",
    :type => :get,
    :desc => "Get notes",
  )
  #Return list of note
  get "/v1/:taxonomy/notes" do
    protected_api "v1|get|/notes"
    Tire.configure do 
      logger STDOUT
    end
    args = params.symbolize_keys!
    limit = args.has_key?(:limit) ? args[:limit].to_i : Notes::FIND_DEFAULT[:limit]
    if args[:fixtures]
      items = [ ApiAdapter::Note.new(ApiAdapter::Note.fixture) ]
    else
      items = ApiAdapter::Note.search do

       if [:user, :client, :contract, :content, :application, :user_id, :client_id, :contract_id].any?{|field| args.has_key?(field)}
          query do
            boolean do
              #try to find fields
              [:user, :client, :contract, :content, :application].each do |field|
                if args.has_key?(field)
                  if args[field].size > 0
                    must { string "#{field}:#{args[field]}" }
                  else
                    must { string "_missing_:#{field}" }
                  end
                end
              end

              #try to find field_id
              [:user_id, :client_id, :contract_id].each do |field|
                if args.has_key?(field)
                  if args[field].size > 0
                    must { string "#{field}:#{args[field]}" }
                  else
                    must { string "_missing_:#{field}" }
                  end
                end
              end

            end
          end
        end
        #pagination
        # - limit
        size limit
        # - page
        from (args.has_key?(:offset) ? args[:offset].to_i : Notes::FIND_DEFAULT[:offset] )*limit

        sort { by :created_at, 'desc' }
      end
      items_count = items.total
    end
    data = { 
      notes: items.collect{|c| c.attributes }, 
      total_count: items_count
    }
    render_output data
  end


  ApiDoc::Method.new(
    :class_name => ApiAdapter::Note,
    :version => :v1,
    :url => "/notes/:id",
    :type => :get,
    :desc => "Get note",
  )
  #Return one client specified by ID
  get "/v1/:taxonomy/notes/:id" do
    protected_api "v1|get|/notes/:id"

    v1_get ApiAdapter::Note, params
  end

  ApiDoc::Method.new(
    :class_name => ApiAdapter::Note,
    :version => :v1,
    :url => "/notes",
    :type => :post,
    :desc => "Create note",
  )
  #Create note
  post "/v1/:taxonomy/notes" do
    protected_api "v1|post|/notes"

    v1_create ApiAdapter::Note, params
  end

  ApiDoc::Method.new(
    :class_name => ApiAdapter::Note,
    :version => :v1,
    :url => "/notes/:id",
    :type => :put,
    :desc => "Update note",
  )

  put "/v1/:taxonomy/notes/:id" do
    protected_api "v1|put|/notes/:id"

    v1_update ApiAdapter::Note, params
  end

  ApiDoc::Method.new(
    :class_name => ApiAdapter::Note,
    :version => :v1,
    :url => "/notes/:id",
    :type => :delete,
    :desc => "Delete note",
  )

  delete "/v1/:taxonomy/notes/:id" do
    protected_api "v1|delete|/notes/:id"

    v1_delete ApiAdapter::Note, params
  end

end
