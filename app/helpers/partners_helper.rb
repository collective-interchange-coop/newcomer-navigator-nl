# frozen_string_literal: true

module PartnersHelper # rubocop:todo Style/Documentation
  def partners_map
    @partners_map ||= PartnerCollectionMap.find_or_create_by(identifier: 'partners')
  end
end
