# frozen_string_literal: true

class JourneyStage < BetterTogether::Category # rubocop:todo Style/Documentation
  has_many :journey_stage_topics, -> { positioned }, dependent: :destroy
  has_many :topics, through: :journey_stage_topics
end
