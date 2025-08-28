# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  require 'better_together/content/block_attributes'
  require 'better_together/content/block'
  require 'better_together/content/template'
  require 'better_together/geography/map'
  require 'better_together/navigation_item'
  require 'better_together/page'
  require 'better_together/person'

  BetterTogether::Content::Block.include(Journeyable)
  BetterTogether::Content::Template.include(NewToNlContentTemplate)
  BetterTogether::NavigationItem.include(NewToNlNavigationItem)
  BetterTogether::Geography::Map.include(NewcomerNavigatorNl::Map)
  BetterTogether::Page.include(Journeyable)
  BetterTogether::Page.include(NewToNlJourneyStage)
  BetterTogether::Page.has_many_journey_stages
  BetterTogether::Page.include(NewToNlTopic)
  BetterTogether::Page.has_many_topics
  BetterTogether::Person.include(NewToNlPerson)
end
