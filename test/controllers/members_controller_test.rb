require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, forum_name: 'TomHaverford'
    assert_response :success
  end

  test "should not show without member" do
    get :show, forum_name: 'DNE'
    assert_redirected_to members_path
  end

end
