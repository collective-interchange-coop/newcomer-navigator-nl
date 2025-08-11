# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerCollectionMap, type: :model do
  describe '.records' do
    let!(:older_partner) { create(:partner, created_at: 2.days.ago) }
    let!(:newer_partner) { create(:partner, created_at: 1.day.ago) }

    before do
      [older_partner, newer_partner].each do |partner|
        building = create(:better_together_infrastructure_building)
        building.create_geospatial_space(space: create(:better_together_geography_space))
        BetterTogether::Infrastructure::BuildingConnection.create!(
          building: building,
          connection: partner,
          position: 1,
          primary_flag: true
        )
      end
    end

    it 'preloads buildings and spaces and orders by creation', :aggregate_failures do
      records = described_class.records.to_a

      expect(records.map(&:id)).to eq([newer_partner.id, older_partner.id])
      expect(records.first.association(:buildings)).to be_loaded
      expect(records.first.buildings.first.association(:space)).to be_loaded
    end
  end

  describe '#leaflet_points' do
    let(:first_partner) { create(:partner) }
    let(:second_partner) { create(:partner) }

    before do
      allow(first_partner).to receive(:leaflet_points).and_return([{ lat: 1.0, lng: 2.0 }])
      allow(second_partner).to receive(:leaflet_points).and_return([{ lat: 3.0, lng: 4.0 }])
      allow(described_class).to receive(:records).and_return([first_partner, second_partner])
    end

    it 'returns unique flattened leaflet points from records' do
      coords = described_class.new.leaflet_points.map { |p| [p[:lat], p[:lng]] }
      expect(coords).to contain_exactly([1.0, 2.0], [3.0, 4.0])
    end
  end

  describe '#spaces' do
    let(:first_space) { create(:better_together_geography_space) }
    let(:second_space) { create(:better_together_geography_space) }
    let(:first_partner) { create(:partner) }
    let(:second_partner) { create(:partner) }

    before do
      allow(first_partner).to receive(:spaces).and_return([first_space])
      allow(second_partner).to receive(:spaces).and_return([second_space])
      allow(described_class).to receive(:records).and_return([first_partner, second_partner])
    end

    it 'returns unique flattened spaces from records' do
      expect(described_class.new.spaces).to contain_exactly(first_space, second_space)
    end
  end
end
