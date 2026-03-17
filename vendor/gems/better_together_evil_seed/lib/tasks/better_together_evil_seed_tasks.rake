# frozen_string_literal: true

namespace :prod do
  desc 'export sanitized data'
  task sanitized_export: :environment do
    BetterTogetherEvilSeed::SanitizedExport.run!
  end
end
