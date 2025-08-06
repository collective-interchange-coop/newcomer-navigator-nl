# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partners map', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'renders the leaflet map on the index page' do # rubocop:todo RSpec/ExampleLength
    map = PartnerCollectionMap.new(identifier: 'partners')
    allow(map).to receive_messages(leaflet_points: [{ lat: 1.0, lng: 2.0 }], center_for_leaflet: [1.0, 2.0], zoom: 10,
                                   viewport: nil)
    allow(PartnerCollectionMap).to receive(:find_or_create_by).with(identifier: 'partners').and_return(map)

    visit partners_path(locale: I18n.locale)

    expect(page).to have_css('.partners-map .map[data-controller="better_together--map"]')
  end
end
