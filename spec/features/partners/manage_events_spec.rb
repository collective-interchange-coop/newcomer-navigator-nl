# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'partner event management', type: :feature do
  include DeviseSessionHelpers

  let!(:partner) { create(:partner, privacy: 'public') }

  before do
    configure_host_platform
  end

  scenario 'shows create event button for permitted user and pre-fills host', :aggregate_failures do
    user = login_as_platform_manager

    # Visit the partner page after login (since login redirects to settings)
    partner_url = "/#{I18n.locale}/partners/#{partner.to_param}"
    visit partner_url

    # Switch to Events tab
    find('a#events-tab').click

    expect(page).to have_link('Create an Event')
    click_link 'Create an Event'

    # We should be on the new event page with host params in URL
    current = Addressable::URI.parse(page.current_url)
    expect(current.path).to end_with('/events/new')
    expect(CGI.parse(current.query)).to include(
      'host_id' => [partner.id],
      'host_type' => [partner.class.name]
    )

    # Check for pre-filled hidden host fields based on actual HTML structure
    expect(page).to have_css(
      "input[type='hidden'][name='event[event_hosts_attributes][0][host_id]'][value='#{partner.id}']", visible: false
    )
    expect(page).to have_css(
      "input[type='hidden'][name='event[event_hosts_attributes][0][host_type]'][value='#{partner.class.name}']", visible: false
    )
  end

  scenario 'lists hosted events for the partner' do
    # Create an event hosted by this partner
    event = create(:event, :upcoming)
    BetterTogether::EventHost.create!(event:, host: partner)

    visit main_app.partner_path(partner, locale: I18n.locale)
    find('a#events-tab').click

    expect(page).to have_content(event.name)
  end
end
