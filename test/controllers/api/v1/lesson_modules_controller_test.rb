require "test_helper"

class Api::V1::LessonModulesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = tenants(:one)
    @user = users(:admin)
    @chapter = chapters(:one)
    @lesson = lessons(:one)
    @token = generate_jwt_token(@user)
  end

  test "should get index of lesson modules" do
    get api_v1_lesson_lesson_modules_path(@lesson), 
        headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
  end

  test "should show lesson module" do
    module_item = @lesson.lesson_modules.create!(
      type: 'TextModule',
      title: 'Test Module',
      description: 'Test Description',
      position: 1,
      content: '<p>Test content</p>'
    )
    
    get api_v1_lesson_lesson_module_path(@lesson, module_item), 
        headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'Test Module', json_response['title']
    assert_equal 'TextModule', json_response['type']
  end

  test "should create text module" do
    assert_difference('LessonModule.count') do
      post api_v1_lesson_lesson_modules_path(@lesson),
           params: {
             lesson_module: {
               type: 'TextModule',
               title: 'New Text Module',
               description: 'New description',
               content: '<h1>New content</h1>'
             }
           },
           headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 'New Text Module', json_response['title']
    assert_equal 'TextModule', json_response['type']
  end

  test "should create video module" do
    assert_difference('VideoModule.count') do
      post api_v1_lesson_lesson_modules_path(@lesson),
           params: {
             lesson_module: {
               type: 'VideoModule',
               title: 'New Video Module',
               description: 'Video description',
               cloudflare_stream_id: '12345678901234567890123456789012'
             }
           },
           headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 'New Video Module', json_response['title']
    assert_equal 'VideoModule', json_response['type']
    assert_equal '12345678901234567890123456789012', json_response['cloudflare_stream_id']
  end

  test "should create assessment module" do
    assert_difference('AssessmentModule.count') do
      post api_v1_lesson_lesson_modules_path(@lesson),
           params: {
             lesson_module: {
               type: 'AssessmentModule',
               title: 'New Assessment',
               description: 'Test assessment',
               settings: {
                 questions: [
                   {
                     text: 'What is 2+2?',
                     type: 'single_choice',
                     options: ['3', '4', '5'],
                     correct_answer: 1,
                     points: 1
                   }
                 ],
                 passing_score: 70
               }
             }
           },
           headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 'New Assessment', json_response['title']
    assert_equal 'AssessmentModule', json_response['type']
    assert_equal 1, json_response['question_count']
  end

  test "should update lesson module" do
    module_item = @lesson.lesson_modules.create!(
      type: 'TextModule',
      title: 'Original Title',
      description: 'Original description',
      position: 1,
      content: '<p>Original content</p>'
    )
    
    patch api_v1_lesson_lesson_module_path(@lesson, module_item),
          params: {
            lesson_module: {
              title: 'Updated Title',
              content: '<p>Updated content</p>'
            }
          },
          headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Updated Title', json_response['title']
    assert_equal '<p>Updated content</p>', json_response['content']
  end

  test "should destroy lesson module" do
    module_item = @lesson.lesson_modules.create!(
      type: 'TextModule',
      title: 'To Delete',
      description: 'Will be deleted',
      position: 1,
      content: '<p>Content</p>'
    )
    
    assert_difference('LessonModule.count', -1) do
      delete api_v1_lesson_lesson_module_path(@lesson, module_item),
             headers: { 'Authorization' => "Bearer #{@token}" }
    end
    
    assert_response :success
  end

  test "should reorder lesson modules" do
    module1 = @lesson.lesson_modules.create!(
      type: 'TextModule',
      title: 'Module 1',
      position: 1,
      content: '<p>Content 1</p>'
    )
    module2 = @lesson.lesson_modules.create!(
      type: 'TextModule',
      title: 'Module 2',
      position: 2,
      content: '<p>Content 2</p>'
    )
    
    patch reorder_api_v1_lesson_lesson_modules_path(@lesson),
          params: { module_ids: [module2.id, module1.id] },
          headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    
    # Check that positions were updated
    module1.reload
    module2.reload
    assert_equal 2, module1.position
    assert_equal 1, module2.position
  end

  test "should require authentication" do
    get api_v1_lesson_lesson_modules_path(@lesson)
    assert_response :unauthorized
  end

  test "should require admin for create" do
    regular_user = users(:user)
    token = generate_jwt_token(regular_user)
    
    post api_v1_lesson_lesson_modules_path(@lesson),
         params: {
           lesson_module: {
             type: 'TextModule',
             title: 'Unauthorized',
             content: '<p>Content</p>'
           }
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    
    assert_response :forbidden
  end

  test "should validate module type" do
    post api_v1_lesson_lesson_modules_path(@lesson),
         params: {
           lesson_module: {
             type: 'InvalidModule',
             title: 'Invalid',
             content: '<p>Content</p>'
           }
         },
         headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'], 'Type is not included in the list'
  end

  test "should validate required fields" do
    post api_v1_lesson_lesson_modules_path(@lesson),
         params: {
           lesson_module: {
             type: 'TextModule',
             # Missing title and content
           }
         },
         headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'], "Title can't be blank"
    assert_includes json_response['errors'], "Content can't be blank"
  end

  private

  def generate_jwt_token(user)
    JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
  end
end
