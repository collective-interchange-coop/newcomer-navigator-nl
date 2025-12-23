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

  def partner_header_cache_key(partner)
    [
      'partner-header',
      partner.id,
      partner.updated_at,
      current_user&.id,
      I18n.locale
    ]
  end

  def partner_about_cache_key(partner)
    [
      'partner-about',
      partner.id,
      partner.updated_at,
      I18n.locale
    ]
  end

  def partner_contact_cache_key(partner)
    [
      'partner-contact',
      partner.id,
      partner.contacts.maximum(:updated_at),
      partner.building_connections.maximum(:updated_at),
      I18n.locale
    ]
  end

  def partner_events_cache_key(partner)
    [
      'partner-events',
      partner.id,
      partner.hosted_events.maximum(:updated_at),
      partner.hosted_events.count,
      current_user&.id,
      I18n.locale
    ]
  end

  def partner_map_cache_key(partner)
    [
      'partner-map',
      partner.id,
      partner.map.updated_at,
      I18n.locale
    ]
  end
end
