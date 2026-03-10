# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

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
    configure_host_platform
    helper.define_singleton_method(:request) do
      OpenStruct.new(
        original_url: 'http://nnnl-prod-zt.btsdev.ca/en',
        fullpath: '/en'
      )
    end
    helper.define_singleton_method(:host_platform) do
      OpenStruct.new(name: 'Newcomer Navigator NL')
    end
    helper.define_singleton_method(:content_for?) do |_name|
      false
    end
    helper.define_singleton_method(:content_for) do |_name|
      nil
    end
    helper.define_singleton_method(:share_button_content) do |_platform|
      'share'
    end
    allow(helper).to receive(:t).and_return('Default content')
  end

  describe '#canonical_link_tag' do
    it 'uses the canonical production host instead of the transport alias' do
      expect(helper.canonical_link_tag).to include('href="https://newcomernavigatornl.ca/en"')
    end
  end

  describe '#open_graph_meta_tags' do
    it 'anchors og:url and og:image to the canonical production host' do
      allow(helper).to receive(:host_community_logo_url).and_return(
        'https://newcomernavigatornl.ca/rails/active_storage/blobs/proxy/example'
      )
      result = helper.open_graph_meta_tags

      expect(result).to include('property="og:url" content="https://newcomernavigatornl.ca/en"')
      expect(result).to include('property="og:image" content="https://newcomernavigatornl.ca/rails/active_storage/blobs/proxy/example"')
      expect(result).not_to include('nnnl-prod-zt.btsdev.ca')
    end
  end

  describe '#share_buttons' do
    it 'uses the canonical production host in share payload urls' do
      result = helper.share_buttons(platforms: [:email])

      expect(result).to include('data-url="https://newcomernavigatornl.ca/en"')
      expect(result).not_to include('http://nnnl-prod-zt.btsdev.ca/en')
    end
  end

  describe '#host_community_logo_url' do
    it 'passes canonical host options to rails_storage_proxy_url' do
      attachment = double('attachment')
      logo = double('logo', attached?: true)
      helper.define_singleton_method(:host_community) do
        OpenStruct.new(logo:, optimized_logo: attachment)
      end

      expect(helper).to receive(:rails_storage_proxy_url).with(
        attachment,
        host: 'newcomernavigatornl.ca',
        protocol: 'https'
      ).and_return('https://newcomernavigatornl.ca/rails/active_storage/blobs/proxy/example')

      helper.host_community_logo_url
    end
  end
end
