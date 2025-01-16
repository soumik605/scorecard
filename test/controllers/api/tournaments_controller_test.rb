require "test_helper"

class Api::TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_tournaments_index_url
    assert_response :success
  end
end
