# -*- encoding : utf-8 -*-

class NotesSinatra < Sinatra::Base
  # enable t & l helper in views for translations
  module CoreV1Methods

    def name_for_klass klass
      klass.to_s.demodulize.underscore
    end

    def pluralized_name_for_klass klass
      klass.to_s.demodulize.underscore.pluralize
    end

    def get_args_from_json
      begin
        Yajl::Parser.parse(request.body, :symbolize_keys => true)
      rescue Yajl::ParseError => e
        render_error 400, ApiError::BadRequest, "Please send valid JSON to POST body."
      end
    end

    def v1_find klass, args
      args.symbolize_keys!
      limit = args.has_key?(:limit) ? args[:limit].to_i : Notes::FIND_DEFAULT[:limit]
      if args[:fixtures]
        items = [ klass.new(klass.fixture) ]
      else
        items = klass.search do

          query do
            #try to find fields
            [:user, :client, :contract].each do |field|
              if args.has_key?(field)
                string "#{field}:#{args[field]}"
              end
            end

            #try to find field_id
            [:user_id, :client_id, :contract_id].each do |field|
              if args.has_key?(field)
                integer "#{field}:#{args[field]}"
              end
            end
          end
          #pagination
          # - limit
          size limit
          # - page
          from args.has_key?(:offset) ? args[:offset].to_i : Notes::FIND_DEFAULT[:offset]

          sort { by :created_at, 'desc' }
        end
        items_count = items.total
      end
      data = {
        pluralized_name_for_klass(klass).to_sym => items.collect{|c| c.attributes },
        total_count: items_count
      }
      render_output data
    end

    def v1_get klass, args
      args.symbolize_keys!
      if args[:fixtures]
        item = klass.new(klass.fixture)
      else
        item = klass.find(args[:id])
      end

      #if there is no client, then raise NotFound
      raise ApiError::NotFound, "#{name_for_klass(klass).humanize} cloudn't be found, params: #{input_params}" unless item

      data = { name_for_klass(klass).to_sym => item.attributes }
      render_output data
    end

    def v1_create klass, args
      args = get_args_from_json

      input_args = {}
      klass.properties.each do |property|
        input_args[property.to_sym] = args[property.to_sym] if args.has_key?(property.to_sym)
      end
      item = klass.new(input_args)
      if item.valid?
        item.save
        render_output(
          {
            :message => "#{name_for_klass(klass).humanize} was succesfully created",
            name_for_klass(klass).to_sym => item.attributes
          } , 201
        )
      else
        render_error 400,
          ApiError::BadRequest,
          {
            :message => "#{name_for_klass(klass).humanize} has problpems with create, check out _errors",
            name_for_klass(klass).to_sym => item.attributes.merge(_errors: item.errors.to_hash)
          }
      end
    end

    def v1_update klass, params
      args = get_args_from_json
      item = klass.find(params[:id])
      if item
        if item.update_attributes args
          render_output :message => "#{name_for_klass(klass).humanize} was succesfully updated",
            name_for_klass(klass).to_sym => item.attributes
        else
          render_error 400,
            ApiError::BadRequest,
            {
              message: "#{name_for_klass(klass).humanize} has problpems with update, check out _errors",
              _errors: item.attributes.merge(_errors: item.errors.to_hash)
            }
        end
      else
        render_error 400, ApiError::NotFound, "Couldn't find any #{name_for_klass(klass).humanize} by given #{params[:id]} id"
      end
    end

    def v1_delete klass, params
      item = klass.find(params[:id])
      unless item
        render_error 400, ApiError::NotFound, "Couldn't find any  by given #{params[:id]} id"
      else
        if item.destroy
          render_output message: "#{name_for_klass(klass).humanize} was succesfully deleted"
        else
          render_error 400, ApiError::BadRequest, item.errors.to_hash
        end
      end
    end

    def v1_delete_many klass, params
      args = get_args_from_json
      render_error 400, ApiError::BadRequest, "You need to specify your delete conditions, please add arguments as json to body of request!" unless args
      validation_object = klass.new(args)
      render_error 400, ApiError::BadRequest, "You need to specify your delete conditions, you are missing: #{validation_object.errors.to_hash}, please add arguments as json to body of request!" unless validation_object.valid? :destroy

      if count = klass.destroy_many(args)
        render_output message: "Deleted #{count} #{pluralized_name_for_klass(klass).humanize}"
      else
        render_error 400, ApiError::BadRequest, "Problem with deleting"
      end
    end

    def v1_finished klass, args
      object = klass.new(args)
      render_error 400, ApiError::BadRequest, "You need to specify your conditions for finished, you are missing: #{object.errors.to_hash}" unless object.valid? :finished

      if object.finished
        render_output message: "Succesfully upload finished"
      else
        render_error 400, ApiError::BadRequest, "Problem with upload finish"
      end
    end


  end

  #include translation helpers
  helpers CoreV1Methods
end