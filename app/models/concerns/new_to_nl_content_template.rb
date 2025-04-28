# frozen_string_literal: true

module NewToNlContentTemplate # rubocop:todo Style/Documentation
  extend ::ActiveSupport::Concern

  included do
    self.available_templates += %w[
      better_together/content/blocks/template/funders
      better_together/content/blocks/template/journey_stages
    ]
  end
end
