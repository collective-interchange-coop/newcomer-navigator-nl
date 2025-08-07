# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partners map', :js do
  include DeviseSessionHelpers

  before do
    configure_host_platform
    login_as_platform_manager
  end

  scenario 'renders the leaflet map on the index page' do # rubocop:todo RSpec/ExampleLength
    map = PartnerCollectionMap.new(identifier: 'partners')
    allow(map).to receive_messages(leaflet_points: [{ lat: 1.0, lng: 2.0 }], center_for_leaflet: [1.0, 2.0], zoom: 10,
                                   viewport: nil)
    allow(PartnerCollectionMap).to receive(:find_or_create_by).with(identifier: 'partners').and_return(map)

    visit partners_path(locale: I18n.locale)

    expect(page).to have_css('.partners-map .map[data-controller="better_together--map"]')
  end
end
