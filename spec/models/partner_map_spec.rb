# frozen_string_literal: true

require 'spec_helper'

module BetterTogether
  module Geography
    class CommunityMap
      def self.mappable_class
        Object
      end
    end
  end
end

class Partner
  def self.model_name
    name
  end
end

require_relative '../../app/models/partner_map'

RSpec.describe PartnerMap, type: :model do
  describe '.mappable_class' do
    it 'returns Partner' do
      expect(described_class.mappable_class).to eq(Partner)
    end
  end
end
