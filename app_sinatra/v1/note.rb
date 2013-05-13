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

    begin
      args = Yajl::Parser.parse(request.body, :symbolize_keys => true)
      args = params.symbolize_keys! if args.nil?
    rescue Exception => e
      args = params.symbolize_keys!
    end
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
                    must { ids Array(args[field]), "_all" }
                  end
                end
              end

              #try to find fields
              IDS_COLUMNS.each do |field|
                if args.has_key?(field)
                  #one item
                  if args[field].size > 0
                    must { terms field, Array(args[field]).collect{|i| i.to_s} }
                  else
                    must { string "_missing_:#{field}" }
                  end
                end
              end

              STRING_COLUMNS.each do |field|
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
                    must { term field, args[field] }
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
        from args.has_key?(:offset) ? args[:offset].to_i : Notes::FIND_DEFAULT[:offset]

        #get order by
        order_by = args.has_key?(:order) ? args[:order].to_s : Notes::FIND_DEFAULT[:order].to_s
        #get order direction
        order_direction = order_by.include?("desc") ? "desc" : "asc"
        #fix name of column
        order_by = order_by.gsub("asc", "").gsub("desc","").strip
        #set order by and direction
        sort { by order_by, order_direction }
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
