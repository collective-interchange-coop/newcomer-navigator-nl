# frozen_string_literal: true

class Partner < BetterTogether::Community # rubocop:todo Style/Documentation
  include NewToNlJourneyStage
  include NewToNlTopic

  has_many_journey_stages
  has_many_topics
end
