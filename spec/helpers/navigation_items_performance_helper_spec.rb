# frozen_string_literal: true

# rubocop:disable RSpec/SpecFilePathFormat, RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/ReceiveMessages, RSpec/VerifiedDoubleReference

require 'rails_helper'

RSpec.describe NewcomerNavigatorNl::NavigationItemsPerformanceHelper, type: :helper do
  before do
    helper.extend(described_class)
    helper.define_singleton_method(:host_platform) { nil }
    helper.define_singleton_method(:platform_header_nav_area) { nil }
    helper.define_singleton_method(:current_user) { nil }
    helper.define_singleton_method(:current_locale) { I18n.locale }
    helper.define_singleton_method(:request) { double(path: '/') }
  end

  describe '#cache_key_for_nav_area' do
    let(:nav_area) do
      instance_double(
        'BetterTogether::NavigationArea',
        id: 10,
        cache_key_with_version: 'nav-area/10-1'
      )
    end

    it 'includes locale, platform, auth context, and request path hash' do
      allow(helper).to receive(:current_user).and_return(nil)
      allow(helper).to receive(:host_platform).and_return(nil)
      allow(helper).to receive(:request).and_return(double(path: '/en/pre-arrival'))
      allow(helper).to receive(:current_locale).and_return(:en)

      key = helper.cache_key_for_nav_area(nav_area)

      expect(key.first).to eq('nav_area_items')
      expect(key.second).to eq(nav_area.cache_key_with_version)
      expect(key.third).to be_present
    end

    it 'changes key when auth context changes' do
      user = double(
        cache_key_with_version: 'users/99-1',
        roles: instance_double('ActiveRecord::Relation', maximum: Time.zone.parse('2026-03-06 12:00:00'), count: 2),
        class: double(joinable_membership_classes: [])
      )
      allow(helper).to receive(:request).and_return(double(path: '/en/pre-arrival'))
      allow(helper).to receive(:host_platform).and_return(nil)
      allow(helper).to receive(:current_locale).and_return(:en)

      allow(helper).to receive(:current_user).and_return(nil)
      guest_key = helper.cache_key_for_nav_area(nav_area)

      allow(helper).to receive(:current_user).and_return(user)
      user_key = helper.cache_key_for_nav_area(nav_area)

      expect(user_key).not_to eq(guest_key)
    end

    it 'changes key when locale changes for the same user context' do
      user = double(
        cache_key_with_version: 'users/99-1',
        roles: instance_double('ActiveRecord::Relation', maximum: Time.zone.parse('2026-03-06 12:00:00'), count: 2),
        class: double(joinable_membership_classes: [])
      )

      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:host_platform).and_return(nil)
      allow(helper).to receive(:request).and_return(double(path: '/en/pre-arrival'))

      allow(helper).to receive(:current_locale).and_return(:en)
      en_key = helper.cache_key_for_nav_area(nav_area)

      allow(helper).to receive(:current_locale).and_return(:fr)
      fr_key = helper.cache_key_for_nav_area(nav_area)

      expect(fr_key).not_to eq(en_key)
    end
  end

  describe '#navigation_item_visible_for?' do
    let(:platform) { instance_double('BetterTogether::Platform', id: 101) }
    let(:child) do
      instance_double(
        'BetterTogether::NavigationItem',
        id: 2,
        visible_to?: true,
        dropdown?: false,
        children: []
      )
    end
    let(:parent) do
      instance_double(
        'BetterTogether::NavigationItem',
        id: 1,
        visible_to?: false,
        dropdown?: true,
        children: [child]
      )
    end

    it 'memoizes visibility checks and keeps dropdown parent visible when a child is visible' do
      allow(helper).to receive(:host_platform).and_return(platform)
      allow(helper).to receive(:current_user).and_return(nil)

      first = helper.navigation_item_visible_for?(parent, platform:)
      second = helper.navigation_item_visible_for?(parent, platform:)

      expect(first).to be(true)
      expect(second).to be(true)
      expect(parent).to have_received(:visible_to?).once
      expect(child).to have_received(:visible_to?).once
    end
  end

  describe '#platform_header_nav_items' do
    let(:visible_item) do
      instance_double(
        'BetterTogether::NavigationItem',
        id: 11,
        visible_to?: true,
        dropdown?: false,
        children: []
      )
    end
    let(:hidden_item) do
      instance_double(
        'BetterTogether::NavigationItem',
        id: 12,
        visible_to?: false,
        dropdown?: false,
        children: []
      )
    end
    let(:nav_items_relation) { instance_double('ActiveRecord::Relation', to_a: [visible_item, hidden_item]) }
    let(:nav_area) do
      instance_double(
        'BetterTogether::NavigationArea',
        id: 55,
        cache_key_with_version: 'nav/55-1',
        top_level_nav_items_includes_children: nav_items_relation
      )
    end

    it 'preloads once and filters out hidden items before rendering' do
      allow(helper).to receive(:platform_header_nav_area).and_return(nav_area)
      allow(helper).to receive(:host_platform).and_return(nil)
      allow(helper).to receive(:request).and_return(double(path: '/en/pre-arrival'))
      allow(helper).to receive(:current_user).and_return(nil)
      allow(helper).to receive(:current_locale).and_return(:en)

      expect(helper.platform_header_nav_items).to eq([visible_item])
      expect(helper.platform_header_nav_items).to eq([visible_item])
      expect(nav_items_relation).to have_received(:to_a).once
    end

    it 'returns permission-appropriate items for guest vs authenticated users' do
      user = double(
        id: 7,
        cache_key_with_version: 'users/7-1',
        roles: instance_double('ActiveRecord::Relation', maximum: Time.zone.parse('2026-03-06 12:00:00'), count: 1),
        class: double(joinable_membership_classes: [])
      )
      guest_visible = instance_double(
        'BetterTogether::NavigationItem',
        id: 21,
        visible_to?: true,
        dropdown?: false,
        children: []
      )
      auth_only = instance_double(
        'BetterTogether::NavigationItem',
        id: 22,
        visible_to?: false,
        dropdown?: false,
        children: []
      )
      nav_items = instance_double('ActiveRecord::Relation', to_a: [guest_visible, auth_only])
      scoped_nav_area = instance_double(
        'BetterTogether::NavigationArea',
        id: 56,
        cache_key_with_version: 'nav/56-1',
        top_level_nav_items_includes_children: nav_items
      )

      allow(helper).to receive(:platform_header_nav_area).and_return(scoped_nav_area)
      allow(helper).to receive(:host_platform).and_return(nil)
      allow(helper).to receive(:request).and_return(double(path: '/en/pre-arrival'))
      allow(helper).to receive(:current_locale).and_return(:en)

      allow(helper).to receive(:current_user).and_return(nil)
      guest_items = helper.platform_header_nav_items
      expect(guest_items).to eq([guest_visible])

      helper.instance_variable_set(:@visible_navigation_items_cache, nil)
      helper.instance_variable_set(:@navigation_item_visibility_cache, nil)

      allow(auth_only).to receive(:visible_to?).with(user, platform: nil).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      user_items = helper.platform_header_nav_items
      expect(user_items).to contain_exactly(guest_visible, auth_only)
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat, RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/ReceiveMessages, RSpec/VerifiedDoubleReference
