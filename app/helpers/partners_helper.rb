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
end
