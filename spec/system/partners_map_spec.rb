# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partners map', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'renders the leaflet map on the index page' do
    map = PartnerCollectionMap.new(identifier: 'partners')
    allow(map).to receive(:leaflet_points).and_return([{ lat: 1.0, lng: 2.0 }])
    allow(map).to receive(:center_for_leaflet).and_return([1.0, 2.0])
    allow(map).to receive(:zoom).and_return(10)
    allow(map).to receive(:viewport).and_return(nil)
    allow(PartnerCollectionMap).to receive(:find_or_create_by).with(identifier: 'partners').and_return(map)

    visit partners_path(locale: I18n.locale)

    expect(page).to have_css('.partners-map .map[data-controller="better_together--map"]')
  end
end
