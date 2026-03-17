# frozen_string_literal: true

begin
  require 'better_together_turnstile'
rescue LoadError
  # noop: host app can still boot even if turnstile extraction gem is not installed
end

module NewToNlCaptchaValidation
  extend ActiveSupport::Concern

  if defined?(BetterTogetherTurnstile::CaptchaValidation)
    include BetterTogetherTurnstile::CaptchaValidation
  end
end
