# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partners map', type: :system do
  before do
    driven_by(:rack_test)

    partner = create(:partner)
    building = create(:better_together_infrastructure_building)
    building.create_geospatial_space(space: create(:better_together_geography_space, latitude: 1.0, longitude: 2.0))
    BetterTogether::Infrastructure::BuildingConnection.create!(
      building: building,
      connection: partner,
      position: 1,
      primary_flag: true
    )
  end

  it 'renders the leaflet map on the index page' do
    visit partners_path(locale: I18n.locale)
    expect(page).to have_css('.partners-map .map[data-controller="better_together--map"]')
  end
end
