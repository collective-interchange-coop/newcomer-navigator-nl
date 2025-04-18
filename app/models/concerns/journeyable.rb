# frozen_string_literal: true

module Journeyable # rubocop:todo Style/Documentation
  extend ::ActiveSupport::Concern

  included do
    has_many :journey_items, as: :journeyable, class_name: 'JourneyItem'
    has_many :journeys, through: :journey_items, class_name: 'Journey'

    def journey_items
      super
    rescue ActiveRecord::AssociationNotFoundError
      self.becomes(self.class.base_class).journey_items
    end

    def journey
      super
    rescue ActiveRecord::AssociationNotFoundError
      self.becomes(self.class.base_class).journey
    end

  end

  def journeyable?
    case self.class.name
    when 'BetterTogether::Content::Hero',
         'BetterTogether::Content::Css',
         'JourneyMap'
      false
    else
      true
    end
  end
end
