require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  def test_creates_comment
    @user=users(:mike)
    jen=users(:jen)
    flexmock(@controller).should_receive(:current_user).and_return(@user)
    flexmock(@user).should_receive(:comment_on).with(jen,"A test")
    facebook_post :create, :comment_receiver=>jen.id,:body=>"A test"
    assert_facebook_redirect_to battles_path(:user_id=>jen.id)
  end
end
