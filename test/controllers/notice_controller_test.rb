require 'test_helper'

class NoticeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
