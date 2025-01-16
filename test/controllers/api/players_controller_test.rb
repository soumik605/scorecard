require "test_helper"

class Api::PlayersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_players_index_url
    assert_response :success
  end

  test "should get show" do
    get api_players_show_url
    assert_response :success
  end
end
