# frozen_string_literal: true

class Topic < BetterTogether::Category # rubocop:todo Style/Documentation
  has_many :journey_stage_topics, -> { positioned }, dependent: :destroy
  has_many :journey_stages, through: :journey_stage_topics
end
