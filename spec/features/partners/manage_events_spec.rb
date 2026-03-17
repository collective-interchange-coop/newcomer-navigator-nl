# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'partner event management', :as_platform_manager, type: :feature do
  let!(:partner) { create(:partner, privacy: 'public') }

  scenario 'shows create event button for permitted user and pre-fills host', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    # Visit the partner page after login (since login redirects to settings)
    partner_url = "/#{I18n.locale}/partners/#{partner.to_param}"
    visit partner_url

    # Switch to Events tab
    find('a#events-tab').click

    create_event_label = I18n.t('partners.show.create_event', default: 'Create an Event')
    expect(page).to have_link(create_event_label)
    click_link create_event_label

    # We should be on the new event page with host params in URL
    current = Addressable::URI.parse(page.current_url)
    expect(current.path).to end_with('/events/new')
    expect(CGI.parse(current.query)).to include(
      'host_id' => [partner.id],
      'host_type' => [partner.class.name]
    )

    # Verify the partner is pre-filled as an event host
    # The EventHost object is new (data-new-record="true") but has the host already attached
    # Note: host_type is stored as the base STI class for polymorphic associations
    within('.nested-fields[data-better-together--event-hosts-target="hostField"]') do
      expect(page).to have_css("input[type='hidden'][name*='[host_id]'][value='#{partner.id}']", visible: false)
      expect(page).to have_css(
        "input[type='hidden'][name*='[host_type]'][value='#{partner.class.base_class.name}']",
        visible: false
      )
      # Should display the partner's name in the existing host display
      expect(page).to have_content(partner.name)
    end
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
