# frozen_string_literal: true

module BetterTogether
  module Api
    module V1
      # JSONAPI resource for Partner (STI subclass of BetterTogether::Community).
      # Required because JSONAPI::Resources resolves STI types to resource classes
      # and Partner records appear in /api/v1/communities results.
      class PartnerResource < CommunityResource
        model_name '::Partner'
      end
    end
  end
end
