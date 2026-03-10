# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Canonical URL generation' do
  around do |example|
    original_base_url = BetterTogether.base_url
    BetterTogether.base_url = 'https://newcomernavigatornl.ca'
    example.run
    BetterTogether.base_url = original_base_url
  end

  it 'anchors canonical, og, share, and media URLs to the canonical host even on an alias host' do
    host! 'nnnl-prod-zt.btsdev.ca'

    get '/en'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('rel="canonical" href="https://newcomernavigatornl.ca/en"')
    expect(response.body).to include('property="og:url" content="https://newcomernavigatornl.ca/en"')
    expect(response.body).to include('data-url="https://newcomernavigatornl.ca/en"')
    expect(response.body).to include('https://newcomernavigatornl.ca/rails/active_storage')
    expect(response.body).not_to include('http://nnnl-prod-zt.btsdev.ca')
    expect(response.body).not_to include('http://bts-5-zt.btsdev.ca')
  end
end
