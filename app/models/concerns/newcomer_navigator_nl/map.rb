# frozen_string_literal: true

module NewcomerNavigatorNl
  # Extends BetterTogether::Geography::Map
  module Map
    extend ActiveSupport::Concern

    included do
      require_dependency 'partner_map'
      require_dependency 'partner_collection_map'
    end
  end
end
