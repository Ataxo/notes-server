# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  STRING_COLUMNS = [ :user, :recipient, :client, :contract, :content, :application ]
  IDS_COLUMNS    = [ :user_id, :recipient_id, :client_id, :contract_id ]
  DATE_COLUMNS   = [ :finished_at, :due_date_at, :created_at, :updated_at ]

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

        if ([:id] | STRING_COLUMNS | IDS_COLUMNS | DATE_COLUMNS).any?{|field| args.has_key?(field)}
          query do
            boolean do

              #try to find id
              [:id].each do |field|
                if args.has_key?(field)
                  if args[field].size > 0
                    must { string "_#{field}:#{args[field]}" }
                  end
                end
              end

              #try to find fields
              (IDS_COLUMNS | STRING_COLUMNS).each do |field|
                if args.has_key?(field)
                  if args[field].size > 0
                    must { string "#{field}:#{args[field]}" }
                  else
                    must { string "_missing_:#{field}" }
                  end
                end
              end


              DATE_COLUMNS.each do |field|
                if args.has_key?(field)
                  #date must be sent as hash with from and to params
                  if args[field].is_a?(Hash)
                    must { range(field, args[field] ) }
                  elsif args[field].size > 0
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
