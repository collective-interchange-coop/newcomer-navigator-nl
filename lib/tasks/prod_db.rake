# frozen_string_literal: true

namespace :prod do
  desc 'export sanitized data'
  task sanitized_export: :environment do
    require 'evil_seed'

    EvilSeed.dump("#{pwd}/tmp/test.sql")
  end
end
