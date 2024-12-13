# frozen_string_literal: true

require 'journeyable'
module NewToNlContentBlock # rubocop:todo Style/Documentation
  extend ::ActiveSupport::Concern

  included do
    new_subclasses = [
      JourneyMap
    ]

    self::SUBCLASSES = (self::SUBCLASSES + new_subclasses).freeze
  end
end
