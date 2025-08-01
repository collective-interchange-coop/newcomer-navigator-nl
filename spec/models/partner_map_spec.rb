require 'spec_helper'

module BetterTogether
  module Geography
    class CommunityMap; end
  end
end

class Partner; end

require_relative '../../app/models/partner_map'

RSpec.describe PartnerMap, type: :model do
  describe '.mappable_class' do
    it 'returns Partner' do
      expect(described_class.mappable_class).to eq(Partner)
    end
  end
end
