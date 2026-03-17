# frozen_string_literal: true

module BetterTogetherTurnstile
  class Railtie < Rails::Railtie
    initializer 'better_together_turnstile.configure' do
      BetterTogetherTurnstile::Configuration.apply_defaults!
    end
  end
end
