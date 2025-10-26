# frozen_string_literal: true

module PartnersHelper # rubocop:todo Style/Documentation
  def partners_map
    @partners_map ||= PartnerCollectionMap.find_or_create_by(identifier: 'partners')
  end

  def partners_cache_key(partners)
    [
      partners.maximum(:updated_at),
      partners.size,
      I18n.locale,
      current_user&.id,
      'partners-grid-v1'
    ]
  end

  def partner_members_cache_key(partner)
    [
      'partner-members',
      partner.id,
      partner.person_community_memberships.maximum(:updated_at),
      partner.person_community_memberships.count,
      I18n.locale,
      'v1'
    ]
  end

  def partner_show_cache_key(partner)
    [
      'partner-show',
      partner.id,
      partner.updated_at,
      partner.contact_details.maximum(:updated_at),
      partner.hosted_events.maximum(:updated_at),
      I18n.locale,
      current_user&.id,
      'v1'
    ]
  end
end
