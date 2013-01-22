# -*- encoding : utf-8 -*-
require './test/test_helper'

class NoteSinatraV1Test < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    NotesSinatra.new
  end

  context "Notes Sinatra - V1 - Note" do
    setup do
      auth = Auth.new(name: "TestUnit", taxonomies: :all, methods: :all )
      Auth.save
      header "Api-Token", auth.api_token
      ApiAdapter::Note.index.refresh
    end

    context "fixture" do
      should "get notes" do
        get "/v1/sandbox/notes?fixtures=true"

        assert_equal last_response.status, 200, "response should have code: 200"
        output = Yajl::Parser.parse(last_response.body)
        
        assert output.has_key?("notes"), "Response should have notes"
        assert output["notes"].is_a?(Array), "Should be array of notes"
        assert output["notes"].first.is_a?(Hash), "Response should have notes -> note"
        
        note = output["notes"].first
        
        ApiAdapter::Note.fixture.each do |field, value| 
          assert_equal note[field.to_s], value, "Note should have required #{field}"
        end
      end

      should "get specific note" do
        get "/v1/sandbox/notes/1234?fixtures=true"
        
        assert_equal last_response.status, 200, "response should have code: 200"
        output = Yajl::Parser.parse(last_response.body)
        
        assert output.has_key?("note"), "Response should have note"

        ApiAdapter::Note.fixture.each do |field, value| 
          assert_equal output["note"][field.to_s], value, "Note should have required #{field}"
        end
      end
    end

    context "real data" do
      should "get notes" do
        get "/v1/sandbox/notes"

        assert_equal last_response.status, 200, "response should have code: 200"
        output = Yajl::Parser.parse(last_response.body)
        
        assert output.has_key?("total_count"), "Response should have count"
        assert output.has_key?("notes"), "Response should have notes"
        assert output["notes"].is_a?(Array), "Should be array of notes"
        assert output["notes"].first.is_a?(Hash), "Response should have notes -> note"
        
        output["notes"].each do |note|
          ApiAdapter::Note.properties.each do |field| 
            assert note.has_key?(field.to_s), "Note should have #{field}"
          end
        end
      end

      should "get specific note" do
        note = ApiAdapter::Note.new( :contract => "Test", :content => "test")
        note.save
        get "/v1/sandbox/notes/#{note.id}"
        
        assert_equal last_response.status, 200, "response should have code: 200"
        output = Yajl::Parser.parse(last_response.body)
        
        assert output.has_key?("note"), "Response should have note"

        ApiAdapter::Note.properties.each do |field| 
          assert output["note"].has_key?(field.to_s), "Note should have #{field}"
        end
      end

      should "create new note" do
        delete "/v1/sandbox/notes/#{ApiAdapter::Note.fixture[:id]}"
        
        before = ApiAdapter::Note.count
        post "/v1/sandbox/notes", Yajl::Encoder.encode(ApiAdapter::Note.fixture)
        ApiAdapter::Note.index.refresh
        assert_equal last_response.status, 201, "response should have code: 201 #{last_response.body}"
        assert_equal ApiAdapter::Note.count, before + 1, "notes count should be +1"
      end

      should "return error on new note with invalid data" do
        post "/v1/sandbox/notes", Yajl::Encoder.encode({:test => 1})
        assert_equal last_response.status, 400, "response should have code: 400 #{last_response.body}"
      end

      should "return error on new note with invalid json" do
        post "/v1/sandbox/notes", "BAD JSON"
        assert_equal last_response.status, 400, "response should have code: 400 #{last_response.body}"
      end

      should "create, update and delete note" do
        delete "/v1/sandbox/notes/123456789"

        before = ApiAdapter::Note.count
        pp Yajl::Encoder.encode(ApiAdapter::Note.fixture)
        post "/v1/sandbox/notes", Yajl::Encoder.encode(ApiAdapter::Note.fixture)
        ApiAdapter::Note.index.refresh
        id = Yajl::Parser.parse(last_response.body, symbolize_keys: true)[:note][:id]
        assert_equal last_response.status, 201, "POST response should have code: 201 #{last_response.body}"
        assert_equal ApiAdapter::Note.count, before + 1, "notes count should be +1"

        get "/v1/sandbox/notes/#{id}"
        assert_equal Yajl::Parser.parse(last_response.body, symbolize_keys: true)[:note][:content], ApiAdapter::Note.fixture[:content], "Should have same content"

        content = "Changed content"
        put "/v1/sandbox/notes/#{id}", Yajl::Encoder.encode(content: content)
        ApiAdapter::Note.index.refresh
        assert_equal last_response.status, 200, "PUT response should have code: 200 #{last_response.body}"
        get "/v1/sandbox/notes/#{id}"
        assert_equal Yajl::Parser.parse(last_response.body, symbolize_keys: true)[:note][:content], content, "Should have same updated content"

        delete "/v1/sandbox/notes/#{id}"
        ApiAdapter::Note.index.refresh
        assert_equal last_response.status, 200, "DELETE response should have code: 200 #{last_response.body}"
        assert_equal ApiAdapter::Note.count, before, "notes count should be -1"
      end

      should "return error on delete nonexisting note" do
        delete "/v1/sandbox/notes/111111111"
        assert_equal last_response.status, 400, "invalid DELETE response should have code: 400 #{last_response.body}"
      end

    end
  end
end