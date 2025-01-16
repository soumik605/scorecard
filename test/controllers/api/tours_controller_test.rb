require "test_helper"

class Api::ToursControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_tours_index_url
    assert_response :success
  end
end
