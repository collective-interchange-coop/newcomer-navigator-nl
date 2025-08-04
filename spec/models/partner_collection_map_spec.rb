# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerCollectionMap, type: :model do
  def connect_partner_with_space(space: nil, latitude: nil, longitude: nil)
    space ||= create(:better_together_geography_space, latitude: latitude, longitude: longitude)
    building = create(:better_together_infrastructure_building)
    building.create_geospatial_space(space: space)
    partner = create(:partner)
    BetterTogether::Infrastructure::BuildingConnection.create!(building: building, connection: partner, position: 1)
    [partner, space]
  end

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
    it 'returns unique flattened leaflet points from records', :aggregate_failures do
      partner1, = connect_partner_with_space(latitude: 1.0, longitude: 2.0)
      partner2, = connect_partner_with_space(latitude: 3.0, longitude: 4.0)

      allow(described_class).to receive(:records).and_return([partner1, partner2])

      coords = described_class.new.leaflet_points.map { |p| [p[:lat], p[:lng]] }
      expect(coords).to contain_exactly([1.0, 2.0], [3.0, 4.0])
    end
  end

  describe '#spaces' do
    it 'returns unique flattened spaces from records', :aggregate_failures do
      partner1, space1 = connect_partner_with_space
      partner2, space2 = connect_partner_with_space

      allow(described_class).to receive(:records).and_return([partner1, partner2])

      expect(described_class.new.spaces).to contain_exactly(space1, space2)
    end
  end
end
