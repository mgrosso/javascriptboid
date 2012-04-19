require 'test_helper'

class FlocksControllerTest < ActionController::TestCase
  setup do
    @flock = flocks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flocks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flock" do
    assert_difference('Flock.count') do
      post :create, flock: { align: @flock.align, avoid: @flock.avoid, boids: @flock.boids, boidsize: @flock.boidsize, center: @flock.center, goalseek: @flock.goalseek, height: @flock.height, jitter: @flock.jitter, name: @flock.name, width: @flock.width }
    end

    assert_redirected_to flock_path(assigns(:flock))
  end

  test "should show flock" do
    get :show, id: @flock
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flock
    assert_response :success
  end

  test "should update flock" do
    put :update, id: @flock, flock: { align: @flock.align, avoid: @flock.avoid, boids: @flock.boids, boidsize: @flock.boidsize, center: @flock.center, goalseek: @flock.goalseek, height: @flock.height, jitter: @flock.jitter, name: @flock.name, width: @flock.width }
    assert_redirected_to flock_path(assigns(:flock))
  end

  test "should destroy flock" do
    assert_difference('Flock.count', -1) do
      delete :destroy, id: @flock
    end

    assert_redirected_to flocks_path
  end
end
