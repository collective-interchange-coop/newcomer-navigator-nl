# frozen_string_literal: true

module BetterTogetherTurnstile
  module CaptchaValidation
    extend ActiveSupport::Concern

    included do
      def validate_captcha_if_enabled?
        return true unless defined?(Cloudflare::Turnstile::Rails)
        return true if Cloudflare::Turnstile::Rails.configuration.site_key.blank?

        valid_turnstile?(model: resource)
      end

      def handle_captcha_validation_failure(resource)
        resource.errors.add(
          :base,
          I18n.t(
            'devise.registrations.new.captcha_failed',
            default: 'Security verification failed. Please complete the security check and try again.'
          )
        )
        respond_with resource
      end
    end
  end
end
