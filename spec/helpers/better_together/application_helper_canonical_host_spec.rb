# frozen_string_literal: true

require 'rails_helper'

FakeRequest = Struct.new(:fullpath, :original_url, keyword_init: true)
FakePlatform = Struct.new(:name, keyword_init: true)
RSpec.describe BetterTogether::ApplicationHelper, type: :helper do
  around do |example|
    original_base_url = BetterTogether.base_url
    BetterTogether.base_url = 'https://newcomernavigatornl.ca'
    example.run
    BetterTogether.base_url = original_base_url
  end

  before do
    helper.singleton_class.include(described_class)
    helper.singleton_class.include(BetterTogether::ShareButtonsHelper)
    helper.define_singleton_method(:request) do
      FakeRequest.new(
        original_url: 'http://nnnl-prod-zt.btsdev.ca/en',
        fullpath: '/en'
      )
    end
    helper.define_singleton_method(:host_platform) do
      FakePlatform.new(name: 'Newcomer Navigator NL')
    end
    helper.define_singleton_method(:content_for?) { |_name| false }
    helper.define_singleton_method(:content_for) { |_name| nil }
    helper.define_singleton_method(:share_button_content) { |_platform| 'share' }
    allow(helper).to receive(:t).and_return('Default content')
  end

  it 'uses the canonical production host in the canonical link tag' do
    expect(helper.canonical_link_tag).to include('href="https://newcomernavigatornl.ca/en"')
  end

  it 'uses the canonical production host in og:url' do
    allow(helper).to receive(:host_community_logo_url).and_return(logo_url)

    expect(helper.open_graph_meta_tags).to include(
      'property="og:url" content="https://newcomernavigatornl.ca/en"'
    )
  end

  it 'uses the canonical production host in og:image' do
    allow(helper).to receive(:host_community_logo_url).and_return(logo_url)

    expect(helper.open_graph_meta_tags).to include(
      'property="og:image" content="https://newcomernavigatornl.ca/rails/active_storage/blobs/proxy/example"'
    )
  end

  it 'uses the canonical production host in share payload urls' do
    expect(helper.share_buttons(platforms: [:email])).to include(
      'data-url="https://newcomernavigatornl.ca/en"'
    )
  end

  def logo_url
    'https://newcomernavigatornl.ca/rails/active_storage/blobs/proxy/example'
  end
end
