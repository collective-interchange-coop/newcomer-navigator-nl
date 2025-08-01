require 'spec_helper'

module BetterTogether
  module Geography
    class CommunityMap; end
  end
end

require_relative '../../app/models/partner_map'
require_relative '../../app/models/partner_collection_map'

RSpec.describe PartnerCollectionMap, type: :model do
  describe '.records' do
    it 'preloads buildings and their spaces and orders by creation' do
      relation = double('relation')
      allow(described_class).to receive(:mappable_class).and_return(relation)

      expect(relation).to receive(:includes).with(buildings: [:space]).and_return(relation)
      expect(relation).to receive(:joins).with(buildings: [:space]).and_return(relation)
      expect(relation).to receive(:order).with(created_at: :desc).and_return(:ordered)

      expect(described_class.records).to eq(:ordered)
    end
  end

  describe '#leaflet_points' do
    it 'returns unique flattened leaflet points from records' do
      record1 = double('record', leaflet_points: [1, 2])
      record2 = double('record', leaflet_points: [2, 3])
      allow(described_class).to receive(:records).and_return([record1, record2])

      expect(described_class.new.leaflet_points).to match_array([1, 2, 3])
    end
  end

  describe '#spaces' do
    it 'returns unique flattened spaces from records' do
      record1 = double('record', spaces: [1])
      record2 = double('record', spaces: [1, 2])
      allow(described_class).to receive(:records).and_return([record1, record2])

      expect(described_class.new.spaces).to match_array([1, 2])
    end
  end
end
