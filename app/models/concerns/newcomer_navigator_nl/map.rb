# frozen_string_literal: true

module NewcomerNavigatorNl
  # Extends BetterTogether::Geography::Map
  module Map
    extend ActiveSupport::Concern

    included do
      require 'partner_map'
      require 'partner_collection_map'
    end
  end
end
