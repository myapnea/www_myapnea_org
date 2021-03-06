# frozen_string_literal: true

require "application_system_test_case"

# System tests for registration process.
class RegistrationsTest < ApplicationSystemTestCase
  test "register new user" do
    visit new_user_registration_url
    screenshot("register-new-user")
    assert_selector "div", text: "Join our community."
    fill_in "user[username]", with: "AmicableRaven"
    fill_in "user[email]", with: "jsmith@example.com"
    fill_in "user[password]", with: "longpassword"
    screenshot("register-new-user")
    click_on "Next step"
    assert_equal "AmicableRaven", User.last.username
    assert_equal "jsmith@example.com", User.last.email
    screenshot("register-new-user")
    assert_selector "div", text: I18n.t("devise.registrations.signed_up_but_unconfirmed")
  end
end
