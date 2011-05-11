# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../../../test_helper.rb"

class UbiquoFormBuilderTest < ActionView::TestCase

  attr_accessor :params

  def setup
    self.params = { :controller => 'tests', :action => 'index' }
  end

  test "form" do
    # Testing the tester.
    the_form do |ufb|
      assert_equal Ubiquo::Helpers::UbiquoFormBuilder, ufb.class
      concat("AAA")
    end
    assert_select "form" do |list|
      assert_equal "/ubiquo/users/1", list.first.attributes["action"]
    end
    assert_select "form", "AAA"
  end

  test "form field" do
    assert_nothing_thrown { 
      the_form do |form|
        concat( form.text_field :lastname )
        concat( form.hidden_field :lastname )
      end
    }
  end
  
  test "form field text_field" do
    the_form do |form|
      concat( form.text_field :lastname )
      concat( form.text_field :lastname, :class=> "alter" )
    end
    assert_select "form" do |list|
      assert_equal "/ubiquo/users/1", list.first.attributes["action"]
      assert_select "div.form-item" do
        assert_select "label", "Bar"
        assert_select "input[type='text'][name='user[lastname]'][value='Bar']"
        assert_select "input[type='text'][name='user[lastname]'][value='Bar'][class='alter']"
      end
    end
  end

  test "group" do
    the_form do |f|
      concat( f.group {} )
    end
    assert_select "form div.form-item"
  end

  test "group with block from erb" do
    # TODO: test with an erb block like
#   <% form.submit_group do %>
#    <%= form.create_button %>
#    <%= form.back_button %>
#  <% end %>
    #
    
  end

  test "submit group" do
    the_form do |f|
      concat f.submit_group {}
    end
    assert_select "form div.form-item-submit"
  end

  test "Submit group for new and edit" do
    self.expects(:ubiquo_users_path).returns("/ubiquo/users")
    self.expects(:t).with("ubiquo.create").returns("ubiquo.create-value")
    self.expects(:t).with("ubiquo.save").returns("ubiquo.save-value")
    self.expects(:t).with("ubiquo.back_to_list").returns("ubiquo.back_to_list-value")

    the_form do |f|
      concat( f.submit_group do
        concat f.create_button 
        concat f.back_button
        concat f.update_button
      end )
    end
    
    assert_select "form div.form-item-submit" do |blocks|
      assert_equal 1, blocks.size
      block = blocks.first
      assert_select block, "input[type='submit'][value='ubiquo.create-value']"
      assert_select block, "input[type='submit'][value='ubiquo.save-value']"
      assert_select block, "input[type='button']" do |buttons|
        assert buttons.first.attributes["onclick"].include?( "href=" )
      end
    end
  end

  test "Custom params for submit buttons" do
    self.expects(:ubiquo_users_path).returns("/ubiquo/users")
    self.expects(:t).with("ubiquo.create-custom").returns("ubiquo.create-custom-value")
    self.expects(:t).with("ubiquo.save-custom").returns("ubiquo.save-custom-value")

    the_form do |f|
      concat( f.submit_group( :class => "alter-submit" ) do
        # Custom params
        concat f.create_button( "c-custom", :class => "bt-create2" )
        concat f.create_button( nil, :i18n_label_key => "ubiquo.create-custom")
        concat f.back_button( "back-custom", {:js_function => "alert('foo');", :class => "bt-back2"} )
        concat f.update_button( "u-custom", :class => "bt-update2" )
        concat f.update_button( nil, :i18n_label_key => "ubiquo.save-custom")
      end )
    end
    
    assert_select "form div.alter-submit", 1 do |blocks|
      block = blocks.first
      assert_select block, "input[type='submit'][value='c-custom'][class='bt-create2']"
      assert_select block, "input[type='submit'][value='ubiquo.create-custom-value']"
      assert_select block, "input[type='button'][value='back-custom'][class='bt-back2']" do |buttons|
        assert buttons.first.attributes["onclick"].include?( "alert('foo');" )
      end
      assert_select block, "input[type='submit'][value='u-custom'][class='bt-update2']"
      assert_select block, "input[type='submit'][value='ubiquo.save-custom-value']"
    end
  end

  test "custom_block" do
    the_form do |form|
      form.custom_block do
        concat( '<div class="custom-form-item">' )
        concat( form.label :lastname, "imalabel")
        concat( form.text_field :lastname)
        concat("</div>")
      end
    end

    assert_select "form > div.form-item", 0
    # Only a label (means that text_field has not generated any label)
    assert_select "form label", "imalabel", 1

    assert_select "form input[type='text'][value='Bar']", 1
  end

  test "disable group on selectors" do
    self.expects(:relation_selector).returns("rel")
    assert_nothing_raised{
      the_form do |form|
        concat( form.group :label => "custom_label_group", :type => :fieldset do
          concat( form.relation_selector :actors, :type => :checkbox )
        end )
      end
    }
  end
  protected

  # helper to build a ubiquo form to test
  def the_form( options={}, &proc)
    self.expects(:ubiquo_user_path).returns("/ubiquo/users/1")
    options[:builder] = Ubiquo::Helpers::UbiquoFormBuilder
    user = User.new
    form_for([:ubiquo,user], options, &proc)
  end

end


# Testing purpose class to simulate an ActiveRecord model
class User

  def id
    123
  end

  def lastname
    "Bar"
  end

  def self.human_attribute_name( attr )
    "Bar"
  end
end

