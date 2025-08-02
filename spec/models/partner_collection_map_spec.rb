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

class DummyRelation
  def includes(*)
    self
  end

  def joins(*)
    self
  end

  def order(*)
    :ordered
  end
end

class DummyRecord
  attr_reader :leaflet_points, :spaces

  def initialize(leaflet_points:, spaces: [])
    @leaflet_points = leaflet_points
    @spaces = spaces
  end
end

require_relative '../../app/models/partner_map'
require_relative '../../app/models/partner_collection_map'

RSpec.describe PartnerCollectionMap, type: :model do
  describe '.records' do
    it 'preloads buildings and spaces and orders by creation' do
      relation = DummyRelation.new
      allow(described_class).to receive(:mappable_class).and_return(relation)

      expect(described_class.records).to eq(:ordered)
    end
  end

  describe '#leaflet_points' do
    it 'returns unique flattened leaflet points from records' do
      record1 = DummyRecord.new(leaflet_points: [1, 2])
      record2 = DummyRecord.new(leaflet_points: [2, 3])
      allow(described_class).to receive(:records).and_return([record1, record2])

      expect(described_class.new.leaflet_points).to contain_exactly(1, 2, 3)
    end
  end

  describe '#spaces' do
    it 'returns unique flattened spaces from records' do
      record1 = DummyRecord.new(leaflet_points: [], spaces: [1])
      record2 = DummyRecord.new(leaflet_points: [], spaces: [1, 2])
      allow(described_class).to receive(:records).and_return([record1, record2])

      expect(described_class.new.spaces).to contain_exactly(1, 2)
    end
  end
end
