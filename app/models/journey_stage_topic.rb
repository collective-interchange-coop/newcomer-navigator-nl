# frozen_string_literal: true

class JourneyStageTopic < ApplicationRecord # rubocop:todo Style/Documentation
  include BetterTogether::Positioned
  include BetterTogether::Visible

  belongs_to :journey_stage
  belongs_to :topic
end
