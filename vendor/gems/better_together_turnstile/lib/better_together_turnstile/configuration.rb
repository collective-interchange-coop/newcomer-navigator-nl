# frozen_string_literal: true

module BetterTogetherTurnstile
  module Configuration
    module_function

    def apply_defaults!
      return unless defined?(Cloudflare::Turnstile::Rails)

      Cloudflare::Turnstile::Rails.configure do |config|
        config.site_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SITE_KEY', nil)
        config.secret_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SECRET_KEY', nil)
        config.render = 'explicit'
        config.auto_populate_response_in_test_env = true
      end
    end
  end
end
