# -*- encoding : utf-8 -*-
require './test/test_helper'

class MainSinatraTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    NotesSinatra.new
  end

  context "Notes Sinatra" do

    should "render success" do
      get "/test_success"
      assert_equal last_response.status, 200, "response should have code: 200"
      assert_equal Yajl::Parser.parse(last_response.body)["valid_output"], "ok", "response should have valid JSON and message" 
    end

    should_eventually "render exception 500" do
      get "/test_exception_500"
      assert_equal last_response.status, 500, "response should have code: 500"
    end

    should_eventually "render exception 400" do
      get "/test_exception_400"
      assert_equal last_response.status, 400, "response should have code: 400"
    end

    should "render error" do
      get "/test_error", error_code: 403, error_type: "RaisedError"
      assert_equal last_response.status, 403, "response should have code: 403"
    end

    should "have is_alive check" do
      get '/is_alive'
      assert_equal last_response.status, 200
      assert_nothing_raised do
        Yajl::Parser.parse(last_response.body)
      end
    end

    should "have system_stats.json check" do
      get '/system_stats.json'
      assert_equal last_response.status, 200
      assert_nothing_raised do
        Yajl::Parser.parse(last_response.body)
      end
    end

    should "have change_log.json check" do
      get '/change_log.json'
      assert_equal last_response.status, 200
      assert_nothing_raised do
        Yajl::Parser.parse(last_response.body)
      end
    end

  end
end