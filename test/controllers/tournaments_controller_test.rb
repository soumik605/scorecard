require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tournaments_index_url
    assert_response :success
  end

  test "should get view" do
    get tournaments_view_url
    assert_response :success
  end

  test "should get edit" do
    get tournaments_edit_url
    assert_response :success
  end
end
