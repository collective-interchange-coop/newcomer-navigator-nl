# frozen_string_literal: true

Rails.application.config.to_prepare do
  require 'better_together/navigation_items_helper'
  require_dependency Rails.root.join(
    'app/helpers/newcomer_navigator_nl/navigation_items_performance_helper.rb'
  ).to_s

  already_prepended = BetterTogether::NavigationItemsHelper.ancestors.include?(
    NewcomerNavigatorNl::NavigationItemsPerformanceHelper
  )
  next if already_prepended

  BetterTogether::NavigationItemsHelper.prepend(NewcomerNavigatorNl::NavigationItemsPerformanceHelper)
end
