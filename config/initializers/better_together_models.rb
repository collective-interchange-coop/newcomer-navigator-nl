# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  require_dependency 'better_together/content/block'
  require_dependency 'better_together/content/template'
  require_dependency 'better_together/navigation_item'
  require_dependency 'better_together/page'
  require_dependency 'better_together/person'

  BetterTogether::Content::Block.include(Journeyable)
  BetterTogether::Content::Template.include(NewToNlContentTemplate)
  BetterTogether::NavigationItem.include(NewToNlNavigationItem)
  BetterTogether::Page.include(Journeyable)
  BetterTogether::Page.include(NewToNlJourneyStage)
  BetterTogether::Page.public_send(:has_many_journey_stages)
  BetterTogether::Page.include(NewToNlTopic)
  BetterTogether::Page.public_send(:has_many_topics)
  BetterTogether::Person.include(NewToNlPerson)
end
