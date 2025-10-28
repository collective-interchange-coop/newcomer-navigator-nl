# frozen_string_literal: true

module DeviseSessionHelpers
  include FactoryBot::Syntax::Methods
  include Rails.application.routes.url_helpers
  include BetterTogether::Engine.routes.url_helpers

  def configure_host_platform
    host_platform = BetterTogether::Platform.find_by(host: true)
    if host_platform
      host_platform.update!(privacy: 'public')
    else
      host_platform = create(:better_together_platform, :host, privacy: 'public')
    end

    wizard = BetterTogether::Wizard.find_or_create_by(identifier: 'host_setup')
    wizard.mark_completed

    platform_manager = BetterTogether::User.find_by(email: 'manager@example.test')

    unless platform_manager
      create(
        :user, :confirmed, :platform_manager,
        email: 'manager@example.test',
        password: 'password12345'
      )
    end

    host_platform
  end

  def login_as_platform_manager
    email = 'platform_manager@example.com'
    password = 'password12345'
    user = create(:better_together_user, :confirmed, :platform_manager, email: email, password: password)
    sign_in_user(email, password)
    user
  end

  def sign_in_user(email, password)
    Capybara.reset_session! # Ensure a new session is created
    visit new_user_session_path(locale: I18n.locale)
    fill_in_email_and_password(email, password)
    click_button 'Sign In'
  end

  def sign_up_new_user(token, email, password, person)
    visit better_together.new_user_registration_path(invitation_code: token, locale: I18n.locale)
    fill_in_registration_form(email, password, person)
    click_button 'Sign Up'
    created_user = BetterTogether::User.find_by(email: email)
    created_user.confirm
    created_user
  end

  def fill_in_registration_form(email, password, person) # rubocop:disable Metrics/AbcSize
    fill_in_email_and_password(email, password)
    fill_in 'user[password_confirmation]', with: password
    fill_in 'user[person_attributes][name]', with: person.name
    fill_in 'user[person_attributes][identifier]', with: person.identifier
    fill_in 'user[person_attributes][description]', with: person.description

    # New consent checkboxes introduced in the community engine
    # Only check them if present, since platforms may toggle which apply
    check 'terms_of_service_agreement' if page.has_unchecked_field?('terms_of_service_agreement', wait: 0)
    check 'privacy_policy_agreement' if page.has_unchecked_field?('privacy_policy_agreement', wait: 0)
    return unless page.has_unchecked_field?('code_of_conduct_agreement', wait: 0)

    check 'code_of_conduct_agreement'
  end

  def fill_in_email_and_password(email, password)
    fill_in 'user[email]', with: email
    fill_in 'user[password]', with: password
  end
end
