# -*- encoding : utf-8 -*-
require './test/test_helper'
class AdpaterNoteTest < Test::Unit::TestCase    

  context "Note" do
    setup do
      ApiAdapter::Note.index.refresh
    end

    should "have required properties" do
      assert ApiAdapter::Note.required_properties.keys.size > 0, "should have at least one required"
    end

    should "have count of all records" do
      assert ApiAdapter::Note.count.is_a?(Integer), "Should be integer"
    end

    should "return all attributes" do
      note = ApiAdapter::Note.new().attributes
      ApiAdapter::Note.properties.each do |field|
        assert note.has_key?(field), "Should have #{field}"
      end
    end


    context "creation, deletion & update" do
      setup do 
        ApiAdapter::Note.find(1234556).destroy rescue nil
        ApiAdapter::Note.index.refresh
        @args = ApiAdapter::Note.fixture.merge(:id => 1234556)
        @args_invalid = ApiAdapter::Note.fixture.merge(:content => nil)
        
        @note = ApiAdapter::Note.new(@args)
        @note_invalid = ApiAdapter::Note.new(@args_invalid)
      end

      should "be created with valid args" do
        before = ApiAdapter::Note.count
        assert @note.save , "be saved but it has: #{@note.errors.to_a}"
        ApiAdapter::Note.index.refresh
        assert_equal ApiAdapter::Note.count, before+1, "should add 1 to count" 
        assert @note.destroy , "destroy"
        ApiAdapter::Note.index.refresh
        assert_equal ApiAdapter::Note.count, before, "should be same as before" 
      end

      should "not be created vith invallid args" do
        refute @note_invalid.save, "not saved"
      end

      should "have error messages when invallid data" do
        @note_invalid.save
        assert @note_invalid.errors.any?, "Has errors"
        assert @note_invalid.errors.to_a.size > 0, "should have more errors"
      end

      should "be created and then updated" do
        assert @note.save , "be saved but it has: #{@note.errors.to_a}"
        ApiAdapter::Note.index.refresh
        content = "updated content"
        note = ApiAdapter::Note.find(@args[:id])
        refute_equal note.content, content, "New content should not match with current content"
        assert note.update_attributes(:content => content), "should be updated #{note.errors.to_a}"
        ApiAdapter::Note.index.refresh
        note = ApiAdapter::Note.find(@args[:id])
        assert_equal note.content, content, "New content should match"
      end

    end

  end

end
