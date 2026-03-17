# frozen_string_literal: true

begin
  require 'better_together/turnstile'
rescue LoadError
  # noop: host app can still boot even if better_together-turnstile gem is not installed
end

module NewToNlCaptchaValidation
  extend ActiveSupport::Concern

  if defined?(BetterTogether::Turnstile::CaptchaValidation)
    include BetterTogether::Turnstile::CaptchaValidation
  end
end
