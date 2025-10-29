# frozen_string_literal: true

# Concern for adding Cloudflare Turnstile captcha validation to registration controllers
module NewToNlCaptchaValidation
  extend ActiveSupport::Concern

  included do
    # Override the engine's captcha validation hook to implement Turnstile validation
    # @return [Boolean] true if captcha is valid, false if validation fails
    def validate_captcha_if_enabled?
      # Check if Turnstile gem is available and configured
      return true unless defined?(Cloudflare::Turnstile::Rails)
      return true if Cloudflare::Turnstile::Rails.configuration.site_key.blank?

      # Validate the Turnstile response
      # The valid_turnstile? method automatically adds errors to the resource if validation fails
      valid_turnstile?(model: resource)
    end

    # Override the engine's captcha validation failure handler for custom error messaging
    # @param resource [User] the user resource being created
    def handle_captcha_validation_failure(resource)
      # Add a user-friendly error message
      resource.errors.add(:base, I18n.t('devise.registrations.new.captcha_failed',
                                        # rubocop:todo Layout/LineLength
                                        default: 'Security verification failed. Please complete the security check and try again.'))
      # rubocop:enable Layout/LineLength
      respond_with resource
    end
  end
end
