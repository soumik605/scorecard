require "test_helper"

class Api::StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_stats_index_url
    assert_response :success
  end
end
