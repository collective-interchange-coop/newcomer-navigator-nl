# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerPolicy, type: :policy do # rubocop:todo RSpec/MultipleMemoizedHelpers
  let(:platform) { configure_host_platform }
  let(:community) { create(:better_together_community) }
  let(:partner) { create(:partner, privacy: 'public') }

  let(:platform_manager) { create(:better_together_user, :platform_manager) }
  let(:partner_member) { create(:better_together_user) }
  let(:non_member_user) { create(:better_together_user) }
  let(:guest_user) { nil }

  before do
    # Add partner_member as a member of the partner
    create(:better_together_person_community_membership,
           member: partner_member.person,
           joinable: partner)
  end

  describe '#manage_members?' do # rubocop:todo RSpec/MultipleMemoizedHelpers
    context 'with platform manager' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(platform_manager, partner) }

      it 'allows platform managers to manage members of any partner' do
        expect(policy.manage_members?).to be true
      end
    end

    context 'with partner member' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(partner_member, partner) }

      it 'allows partner members to manage members' do
        expect(policy.manage_members?).to be true
      end
    end

    context 'with non-member user' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(non_member_user, partner) }

      it 'denies non-members from managing members' do
        expect(policy.manage_members?).to be false
      end
    end

    context 'with guest user' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(guest_user, partner) }

      it 'denies guests from managing members' do
        expect(policy.manage_members?).to be false
      end
    end
  end

  describe '#available_people?' do # rubocop:todo RSpec/MultipleMemoizedHelpers
    context 'with platform manager' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(platform_manager, partner) }

      it 'allows platform managers to access available people' do
        expect(policy.available_people?).to be true
      end
    end

    context 'with partner member' do # rubocop:todo RSpec/MultipleMemoizedHelpers
      subject(:policy) { described_class.new(partner_member, partner) }

      it 'allows partner members to access available people' do
        expect(policy.available_people?).to be true
      end
    end
  end
end
