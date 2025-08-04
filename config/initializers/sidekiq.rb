# frozen_string_literal: true

if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
else
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil) }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil) }
  end
end
