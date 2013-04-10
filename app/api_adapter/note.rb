# -*- encoding : utf-8 -*-

module ApiAdapter

  class Note
    include Tire::Model::Persistence

    def self.version
      :v1
    end

    property :id            , type: "string",   index: 'not_analyzed'
    property :application   , type: "string",   index: 'not_analyzed'
    property :client_id     , type: "string",   index: 'not_analyzed'
    property :client        , type: "string",   index: 'not_analyzed'
    property :contract_id   , type: "string",   index: 'not_analyzed'
    property :contract      , type: "string",   index: 'not_analyzed'
    property :user_id       , type: "string",   index: 'not_analyzed'
    property :user          , type: "string",   index: 'not_analyzed'
    property :recipient_id  , type: "string",   index: 'not_analyzed'
    property :recipient     , type: "string",   index: 'not_analyzed'
    property :content       , type: "string",   analyzer: 'czech'
    property :created_at    , type: "date"
    property :updated_at    , type: "date"
    property :due_date_at   , type: "date"
    property :finished_at   , type: "date"

    validates :client_id, :contract_id, :user_id, :numericality => { :only_integer => true }, :allow_nil => true
    validates :content, :presence => true

    after_save :refresh_index

    before_save  :set_date_created
    before_save  :set_date_updated

    def refresh_index
      ApiAdapter::Note.index.refresh
    end

    def self.count
      Tire::Search::Count.new(index_name).perform.value
    end

    def self.required_properties
      { content: true }
    end

    def set_date_created
      unless persisted?
        @created_at ||= Time.now
      end
    end

    def set_date_updated
      @updated_at = Time.now
    end

    def self.fixture
      {
        client_id: 123,
        contract_id: 1234,
        user_id: 1234,
        content: "Fixture text of note"
      }
    end

  end

end