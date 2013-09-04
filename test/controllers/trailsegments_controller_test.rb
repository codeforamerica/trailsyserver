require 'test_helper'

class TrailsegmentsControllerTest < ActionController::TestCase
  setup do
    @trailsegment = trailsegments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trailsegments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trailsegment" do
    assert_difference('Trailsegment.count') do
      post :create, trailsegment: { geom: @trailsegment.geom, length: @trailsegment.length, name1: @trailsegment.name1, name2: @trailsegment.name2, name3: @trailsegment.name3, source: @trailsegment.source, steward: @trailsegment.steward }
    end

    assert_redirected_to trailsegment_path(assigns(:trailsegment))
  end

  test "should show trailsegment" do
    get :show, id: @trailsegment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trailsegment
    assert_response :success
  end

  test "should update trailsegment" do
    patch :update, id: @trailsegment, trailsegment: { geom: @trailsegment.geom, length: @trailsegment.length, name1: @trailsegment.name1, name2: @trailsegment.name2, name3: @trailsegment.name3, source: @trailsegment.source, steward: @trailsegment.steward }
    assert_redirected_to trailsegment_path(assigns(:trailsegment))
  end

  test "should destroy trailsegment" do
    assert_difference('Trailsegment.count', -1) do
      delete :destroy, id: @trailsegment
    end

    assert_redirected_to trailsegments_path
  end
end
