# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partners map', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'renders the leaflet map on the index page' do
    partner = create(:partner)
    allow(partner).to receive(:leaflet_points).and_return([{ lat: 1.0, lng: 2.0 }])
    allow(PartnerCollectionMap).to receive(:records).and_return([partner])

    visit partners_path(locale: I18n.locale)

    expect(page).to have_css('.partners-map .map[data-controller="better_together--map"]')
  end
end
