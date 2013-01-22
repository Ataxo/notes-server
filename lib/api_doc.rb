# -*- encoding : utf-8 -*-
module ApiDoc

  def self.models
    unless @models
      @models = {}
      init
    end
    @models
  end

  def self.methods
    @methods ||= {}
  end

  def self.init
    ApiAdapter.constants.each do |klass|
      Model.new("ApiAdapter::#{klass}".constantize)
    end
  end

  class Model
    attr_accessor :class_name, :desc, :version
    def initialize klass
      if klass.is_a?(Hash)
        @class_name = klass[:class_name]
        @version = klass[:version]
      else
        @class_name = klass
        @version = klass.version
      end

      ApiDoc.models[@version] ||= []
      ApiDoc.models[@version] << self
      self
    end

    def name
      @class_name.to_s.demodulize
    end

    def properties
      @class_name.properties.inject({}) do |output, name|
        output[name] = {}
        output[name][:default] = @class_name.property_defaults[name.to_sym] if @class_name.property_defaults.has_key?(name.to_sym)
        output[name][:required] = @class_name.required_properties.has_key?(name.to_sym)
        output[name][:type] = @class_name.mapping_to_hash[@class_name.to_s.underscore.to_sym][:properties][name.to_sym][:type] rescue ""
        output
      end
    end

    def fixture
      @class_name.fixture
    end

    def api_methods
      ApiDoc.methods[@version].select{|m| m.class_name == @class_name}
    end
  end

  class Method
    attr_accessor :class_name, :type, :url, :desc, :version
    def initialize args = {}
      @class_name = args[:class_name]
      @type = args[:type]
      @url = args[:url]
      @desc = args[:desc]
      @version = args[:version]

      ApiDoc.methods[@version] ||= []
      ApiDoc.methods[@version] << self
      self
    end

    def auth_key
      "#{@version}|#{@type}|#{@url}"
    end

    def access_path version
      "#{version}|#{@type}|#{@url}"
    end
  end


end