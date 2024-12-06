# frozen_string_literal: true

class JourneyStagesController < BetterTogether::CategoriesController # rubocop:todo Style/Documentation
  protected

  def resource_class
    JourneyStage
  end

  def resource_collection
    super.positioned
  end
end
