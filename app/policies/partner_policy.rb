# frozen_string_literal: true

class PartnerPolicy < BetterTogether::CommunityPolicy # rubocop:todo Style/Documentation
  def index?
    true
  end

  alias available_people? show?

  # Check if user can manage members (view members tab and add/remove members)
  # Allows:
  # - Platform managers (can manage all partners)
  # - Partner members (can view and potentially add members to their partner)
  def manage_members?
    return false unless agent

    # Platform managers can manage members of any partner
    return true if permitted_to?('manage_platform')

    # Users who are members of this partner can manage members
    record.person_community_memberships.exists?(member_id: agent.id)
  end

  def create?
    permitted_to?('manage_platform')
  end

  def destroy?
    permitted_to?('manage_platform')
  end

  class Scope < BetterTogether::CommunityPolicy::Scope # rubocop:todo Style/Documentation
    def resolve
      scope.i18n.where(permitted_query).order(name: :asc)
    end

    protected

    # rubocop:todo Metrics/MethodLength
    def permitted_query # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      communities_table = Partner.arel_table
      person_community_memberships_table = ::BetterTogether::PersonCommunityMembership.arel_table

      # Only list communities that are public and where the current person is a member or a creator
      query = communities_table[:privacy].eq('public')

      if agent
        query = query.or(
          communities_table[:id].in(
            person_community_memberships_table
              .where(person_community_memberships_table[:member_id]
              .eq(agent.id))
              .project(:joinable_id)
          )
        ).or(
          communities_table[:creator_id].eq(agent.id)
        )
      end

      query
    end
    # rubocop:enable Metrics/MethodLength
  end
end
