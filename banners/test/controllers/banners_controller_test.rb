require 'test_helper'

class BannersControllerTest < ActionController::TestCase
  test "should get banners" do
    get :banners
    assert_response :success
  end

end
