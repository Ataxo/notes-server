# -*- encoding : utf-8 -*-
require './test/test_helper'
class AuthTest < Test::Unit::TestCase    

  context "Auth" do

    setup do 
      @args = {
        name: "TestApp",
        api_token: "12345678901234567890",
        taxonomies: :all,
        methods: :all,
      }
      @auth = Auth.new(@args)

      @args_limited = {
        name: "TestLimitedApp",
        api_token: "1234567890",
        taxonomies: [:mediatel],
        methods: ["get/test"],
      }
      @auth_limited = Auth.new(@args_limited)
    end

    should "have values" do
      @args.each do |name, value|
        assert_equal @auth.send(name), value, "Should have #{name} same"
      end
    end

    should "generate token when it is not specified" do
      auth = Auth.new(@args.merge(:api_token => nil))
      assert_not_nil auth.api_token
    end

    should "return access to taxonomy" do
      assert @auth.taxonomy?("testing"), "All taxonomies - (string) true"
      assert @auth.taxonomy?(:testing), "All taxonomies - (symbol) true"
      
      assert @auth_limited.taxonomy?("mediatel"), "Limited taxonomies - (string) true"
      assert @auth_limited.taxonomy?(:mediatel), "Limited taxonomies - (symbol) true"

      refute @auth_limited.taxonomy?("limited"), "Limited taxonomies - (string) false"
      refute @auth_limited.taxonomy?(:limited), "Limited taxonomies - (symbol) false"

      assert @auth_limited.taxonomy?("sandbox"), "Limited taxonomies - sandbox (string) true"
      assert @auth_limited.taxonomy?(:sandbox), "Limited taxonomies - sandbox (symbol) true"
    end

    should "return access to method" do
      assert @auth.method?("get/test"), "All methods - true"
      
      assert @auth_limited.method?("get/test"), "Limited methods - true"
      refute @auth_limited.method?("get/test_limited"), "Limited methods - false"
    end

    should "return access by name" do
      auth = Auth.get_by_name @args[:name]
      assert_equal auth, Auth.applications[@args[:api_token]]
    end

    should "be contained in main model" do
      assert Auth.applications.is_a?(Hash), "Is a Hash"
      assert Auth.applications.has_key?(@auth.api_token), "Has app"
      assert Auth.application?(@auth.api_token), "Has app ?"
      assert_equal Auth.applications[@auth.api_token], @auth, "Is same instance"
    end

    should "be saved & loaded into YML" do
      apps = Marshal.load(Marshal.dump(Auth.applications))
      assert Auth.save("tmp/testing_access_backup.yml")
      assert Auth.load("tmp/testing_access_backup.yml")
      [:name, :api_token, :taxonomies, :methods].each do |method|
        Auth.applications.each do |api_token, app|
          assert_equal app.send(method), apps[api_token].send(method), "Token: #{api_token} method shoud be same #{method}"
        end
      end
    end
  end
end
