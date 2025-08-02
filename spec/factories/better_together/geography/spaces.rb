# frozen_string_literal: true

FactoryBot.define do
  factory :better_together_geography_space, class: 'BetterTogether::Geography::Space', aliases: [:space] do
    id { Faker::Internet.uuid }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    elevation { 0 }
  end
end
