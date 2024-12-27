require "test_helper"

class ImageGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image_group = image_groups(:one)
  end

  test "should get index" do
    get image_groups_url, as: :json
    assert_response :success
  end

  test "should create image_group" do
    assert_difference("ImageGroup.count") do
      post image_groups_url, params: { image_group: {} }, as: :json
    end

    assert_response :created
  end

  test "should show image_group" do
    get image_group_url(@image_group), as: :json
    assert_response :success
  end

  test "should update image_group" do
    patch image_group_url(@image_group), params: { image_group: {} }, as: :json
    assert_response :success
  end

  test "should destroy image_group" do
    assert_difference("ImageGroup.count", -1) do
      delete image_group_url(@image_group), as: :json
    end

    assert_response :no_content
  end
end
