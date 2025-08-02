# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    id { Faker::Internet.uuid }
    identifier { Faker::Internet.unique.uuid }
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    privacy { 'public' }
    host { false }
    slug { name.parameterize }
  end
end
