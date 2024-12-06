# frozen_string_literal: true

module NewToNlPerson # rubocop:todo Style/Documentation
  extend ::ActiveSupport::Concern

  included do
    has_one :journey, class_name: 'Journey', dependent: :destroy
    has_many :journey_items, through: :journey

    after_create :create_journey
  end
end
