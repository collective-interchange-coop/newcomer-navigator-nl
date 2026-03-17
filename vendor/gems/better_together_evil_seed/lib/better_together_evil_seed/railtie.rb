# frozen_string_literal: true

module BetterTogetherEvilSeed
  class Railtie < Rails::Railtie
    initializer 'better_together_evil_seed.configure' do
      begin
        BetterTogetherEvilSeed::EvilSeedConfiguration.apply!
      rescue LoadError
        Rails.logger.info('[better_together_evil_seed] evil-seed gem not available; configuration skipped')
      end
    end

    rake_tasks do
      load File.expand_path('../tasks/better_together_evil_seed_tasks.rake', __dir__)
    end
  end
end
