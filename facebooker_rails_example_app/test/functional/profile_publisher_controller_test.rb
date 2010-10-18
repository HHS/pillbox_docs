require File.dirname(__FILE__) + '/../test_helper'

class ProfilePublisherControllerTest < ActionController::TestCase
  
  def test_get_interface
    facebook_get :index, :fb_sig_profile_user=>"1234",:method=>"publisher_getInterface"
    assert_template "_form"
  end
  
  def test_creates_attack
    facebook_get :index, :fb_sig_profile_user=>"1234",
      :app_params=>{:attack=>{:move_id=>moves(:chop).id}},
      :method=>"publisher_getFeedStory"
    assert_match /publisher_getFeedStory/,@response.body
  end
  
end
