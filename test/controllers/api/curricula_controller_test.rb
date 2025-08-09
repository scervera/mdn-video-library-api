require "test_helper"

class Api::CurriculaControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @curriculum = curriculums(:one)
    @token = generate_token(@user)
  end

  test "should get enrollment status for curriculum" do
    get enrollment_status_api_curricula_url(@curriculum), 
        headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal @curriculum.id, json_response['curriculum_id']
    assert_equal @curriculum.title, json_response['curriculum_title']
    assert_includes json_response.keys, 'enrolled'
    assert_includes json_response.keys, 'enrollment_date'
  end

  test "should enroll user in curriculum" do
    # First, ensure user is not enrolled
    @user.user_progress.where(curriculum: @curriculum).destroy_all
    
    assert_difference('UserProgress.count', @curriculum.chapters.count) do
      post enroll_api_curricula_url(@curriculum), 
           headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal 'Successfully enrolled in curriculum', json_response['message']
    assert_equal @curriculum.id, json_response['curriculum_id']
    assert_equal @curriculum.title, json_response['curriculum_title']
  end

  test "should not enroll user if already enrolled" do
    # First, ensure user is not enrolled
    @user.user_progress.where(curriculum: @curriculum).destroy_all
    
    # Then enroll the user
    @curriculum.chapters.each do |chapter|
      @user.user_progress.create!(
        chapter: chapter,
        curriculum: @curriculum,
        completed: false
      )
    end
    
    assert_no_difference('UserProgress.count') do
      post enroll_api_curricula_url(@curriculum), 
           headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Already enrolled in this curriculum', json_response['message']
  end

  test "should include enrollment status in curriculum data" do
    get api_curricula_url(@curriculum), 
        headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_includes json_response.keys, 'enrolled'
    assert_equal @user.enrolled_in?(@curriculum), json_response['enrolled']
  end

  private

  def generate_token(user)
    JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
  end
end
