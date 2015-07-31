require 'test_helper'

class BuilderControllerTest < ActionController::TestCase
  setup do
    @builder = users(:builder)
    @regular_user = users(:user_1)
    @survey = surveys(:built_on_web)
    @question = questions(:web_question)
  end

  test "should get index as builder" do
    login(@builder)
    get :index
    assert_response :success
  end

  test "should not get index as regular user" do
    login(@regular_user)
    get :index
    assert_redirected_to root_path
  end

  test "should get new as builder" do
    login(@builder)
    get :new
    assert_not_nil assigns(:survey)
    assert_response :success
  end

  test "should not get new as regular user" do
    login(@regular_user)
    get :new
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should create survey as builder" do
    login(@builder)
    assert_difference('Survey.count') do
      post :create, survey: { name_en: 'My New Survey', slug: 'my-new-survey', status: 'show' }
    end
    assert_not_nil assigns(:survey)
    assert_equal 'My New Survey', assigns(:survey).name_en
    assert_equal 'my-new-survey', assigns(:survey).slug
    assert_equal 'show', assigns(:survey).status
    assert_redirected_to builder_survey_path(id: assigns(:survey))
  end

  test "should not create survey without name" do
    login(@builder)
    assert_difference('Survey.count', 0) do
      post :create, survey: { name_en: '', slug: 'my-new-survey', status: 'show' }
    end
    assert_not_nil assigns(:survey)
    assert assigns(:survey).errors.size > 0
    assert_equal ["can't be blank"], assigns(:survey).errors[:name_en]
    assert_template 'new'
    assert_response :success
  end

  test "should not create survey as regular user" do
    login(@regular_user)
    assert_difference('Survey.count', 0) do
      post :create, survey: { name_en: 'My New Survey', slug: 'my-new-survey', status: 'show' }
    end
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should show survey as builder" do
    login(@builder)
    get :show, id: @survey
    assert_not_nil assigns(:survey)
    assert_response :success
  end

  test "should not show survey as regular user" do
    login(@regular_user)
    get :show, id: @survey
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should get edit survey as builder" do
    login(@builder)
    get :edit, id: @survey
    assert_not_nil assigns(:survey)
    assert_response :success
  end

  test "should not get edit survey as regular user" do
    login(@regular_user)
    get :edit, id: @survey
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should update survey as builder" do
    login(@builder)
    patch :update, id: @survey, survey: { name_en: 'Updated Survey', slug: 'updated-survey', status: 'hide' }
    assert_not_nil assigns(:survey)
    assert_equal 'Updated Survey', assigns(:survey).name_en
    assert_equal 'updated-survey', assigns(:survey).slug
    assert_equal 'hide', assigns(:survey).status
    assert_redirected_to builder_survey_path(id: assigns(:survey))
  end

  test "should not update survey without name" do
    login(@builder)
    patch :update, id: @survey, survey: { name_en: '', slug: 'updated-survey', status: 'hide' }
    assert_not_nil assigns(:survey)
    assert assigns(:survey).errors.size > 0
    assert_equal ["can't be blank"], assigns(:survey).errors[:name_en]
    assert_template 'edit'
    assert_response :success
  end

  test "should not update survey as regular user" do
    login(@regular_user)
    patch :update, id: @survey, survey: { name_en: 'Updated Survey', slug: 'updated-survey', status: 'hide' }
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should destroy survey as builder" do
    login(@builder)
    assert_difference('Survey.current.count', -1) do
      delete :destroy, id: @survey
    end
    assert_not_nil assigns(:survey)
    assert_redirected_to builder_surveys_path
  end

  test "should not destroy survey as regular user" do
    login(@regular_user)
    assert_difference('Survey.current.count', 0) do
      delete :destroy, id: @survey
    end
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  ## Questions

  test "should get questions as builder" do
    login(@builder)
    get :questions, id: @survey
    assert_not_nil assigns(:survey)
    assert_redirected_to builder_survey_path(id: assigns(:survey))
  end

  test "should not get questions as regular user" do
    login(@regular_user)
    get :questions, id: @survey
    assert_nil assigns(:survey)
    assert_redirected_to root_path
  end

  test "should get new question as builder" do
    login(@builder)
    get :new_question, id: @survey
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_response :success
  end

  test "should not get new question as regular user" do
    login(@regular_user)
    get :new_question, id: @survey
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

  test "should create question as builder" do
    login(@builder)
    assert_difference('Question.count') do
      post :create_question, id: @survey, question: { text_en: 'My New Question', slug: 'my-new-question', display_type: 'radio_input' }
    end
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_equal 'My New Question', assigns(:question).text_en
    assert_equal 'my-new-question', assigns(:question).slug
    assert_equal 'radio_input', assigns(:question).display_type
    assert_redirected_to question_builder_survey_path(id: assigns(:survey), question_id: assigns(:question))
  end

  test "should not create question without text" do
    login(@builder)
    assert_difference('Question.count', 0) do
      post :create_question, id: @survey, question: { text_en: '', slug: 'my-new-question', display_type: 'radio_input' }
    end
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert assigns(:question).errors.size > 0
    assert_equal ["can't be blank"], assigns(:question).errors[:text_en]
    assert_template 'questions/new'
    assert_response :success
  end

  test "should not create question as regular user" do
    login(@regular_user)
    assert_difference('Question.count', 0) do
      post :create_question, id: @survey, question: { text_en: 'My New Question', slug: 'my-new-question', display_type: 'radio_input' }
    end
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

  test "should show question as builder" do
    login(@builder)
    get :question, id: @survey, question_id: @question
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_response :success
  end

  test "should not show question as regular user" do
    login(@regular_user)
    get :question, id: @survey, question_id: @question
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

  test "should get edit question as builder" do
    login(@builder)
    get :edit_question, id: @survey, question_id: @question
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_response :success
  end

  test "should not get edit question as regular user" do
    login(@regular_user)
    get :edit_question, id: @survey, question_id: @question
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

  test "should update question as builder" do
    login(@builder)
    patch :update_question, id: @survey, question_id: @question, question: { text_en: 'Updated Question', slug: 'updated-question', display_type: 'checkbox_input' }
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_equal 'Updated Question', assigns(:question).text_en
    assert_equal 'updated-question', assigns(:question).slug
    assert_equal 'checkbox_input', assigns(:question).display_type
    assert_redirected_to question_builder_survey_path(id: assigns(:survey), question_id: assigns(:question))
  end

  test "should not update question without name" do
    login(@builder)
    patch :update_question, id: @survey, question_id: @question, question: { text_en: '', slug: 'updated-question', display_type: 'checkbox_input' }
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert assigns(:question).errors.size > 0
    assert_equal ["can't be blank"], assigns(:question).errors[:text_en]
    assert_template 'questions/edit'
    assert_response :success
  end

  test "should not update question as regular user" do
    login(@regular_user)
    patch :update_question, id: @survey, question_id: @question, question: { text_en: 'Updated Question', slug: 'updated-question', display_type: 'checkbox_input' }
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

  test "should destroy question as builder" do
    login(@builder)
    assert_difference('Question.current.count', -1) do
      delete :destroy_question, id: @survey, question_id: @question
    end
    assert_not_nil assigns(:survey)
    assert_not_nil assigns(:question)
    assert_redirected_to builder_survey_path(id: assigns(:survey))
  end

  test "should not destroy question as regular user" do
    login(@regular_user)
    assert_difference('Question.current.count', 0) do
      delete :destroy_question, id: @survey, question_id: @question
    end
    assert_nil assigns(:survey)
    assert_nil assigns(:question)
    assert_redirected_to root_path
  end

end