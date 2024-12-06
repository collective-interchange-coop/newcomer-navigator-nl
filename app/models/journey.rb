# frozen_string_literal: true

class Journey < ApplicationRecord # rubocop:todo Style/Documentation
  belongs_to :person, class_name: 'BetterTogether::Person'
  has_many :journey_items, -> { positioned }
end
