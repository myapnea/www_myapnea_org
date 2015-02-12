class AccountController < ApplicationController
  before_action :authenticate_user!

  def get_started
  end

  def get_started_privacy
  end

  def provider_profile
  end

  def get_started_consent
  end

  def get_started_about_me
    if current_user
      @survey = Survey.find_by_slug("about-me")
      @answer_session = AnswerSession.find_or_create(current_user, @survey)
    end
  end

  def privacy_policy
    if params[:privacy_policy_read]
      current_user.update accepted_privacy_policy_at: Time.zone.now
      if current_user.ready_for_research?
        redirect_to (session[:return_to].present? ? session.delete(:return_to) : home_path), notice: "You have now signed the consent and are ready to participate in research. You can opt out any time by visiting your user account settings."
      else
        redirect_to consent_path, notice: "Please read over and accept the research consent before participating in research."
      end
    else
      load_content
    end
  end

  def accepts_privacy
    current_user.update accepted_privacy_policy_at: Time.zone.now
    redirect_to get_started_consent_path
  end

  def consent
    if params[:consent_read]
      current_user.update_attribute(:accepted_consent_at, Time.zone.now)
      if current_user.ready_for_research?
        redirect_to (session[:return_to].present? ? session.delete(:return_to) : home_path), notice: "You have now signed the consent and are ready to participate in research."
      else
        redirect_to privacy_path, notice: "Please read over and accept the privacy policy before participating in research. You can opt out any time by visiting your user account settings."
      end
    else
      load_content
    end
  end

  def accepts_consent
    current_user.update accepted_consent_at: Time.zone.now
    redirect_to get_started_about_me_path
  end

  def revoke_consent
    current_user.revoke_consent!
    redirect_to account_path, notice: "You have successfully left the research study. If you ever change your mind, just visit your account settings to view the research consent and privacy policy again."
  end

  def set_user_type
    user_types = params.required(:user).permit(:provider, :researcher, :adult_diagnosed, :adult_at_risk, :caregiver_adult, :caregiver_child)
    current_user.update user_types
    if current_user.provider?
      redirect_to get_started_provider_profile_path
    else
      redirect_to get_started_privacy_path
    end
  end

  def dashboard

  end

  def account
    @social_profile = current_user.social_profile || current_user.create_social_profile
  end

  def terms_and_conditions
    render layout: 'layouts/cleantheme'
  end

  def update
    if current_user.update(user_params)
      redirect_to account_path, notice: "Your account settings have been successfully changed."
    else
      @update_for = :user_info
      render "account"
    end
  end

  def change_password
    if current_user.update_with_password(user_params)
      # Sign in the user by passing validation in case the user's password changed
      sign_in current_user, bypass: true
      redirect_to account_path, alert: "Your password has been changed."
    else
      @update_for = :password
      render "account"
    end
  end

  private

  def user_params
    params.required(:user).permit(:email, :first_name, :last_name, :zip_code, :year_of_birth, :password, :password_confirmation, :current_password, :beta_opt_in, :state_code, :country_code, :provider_id, :welcome_message, :photo, :emails_enabled, :slug, :provider_name)
  end

  def load_content
    @pc = YAML.load_file(Rails.root.join('lib', 'data', 'myapnea', 'content', "#{action_name}.#{I18n.locale}.yml"))[I18n.locale.to_s][action_name.to_s]
  end

end
