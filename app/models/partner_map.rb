# frozen_string_literal: true

# Custom Map subtype for Partners
class PartnerMap < BetterTogether::Geography::CommunityMap
  def self.mappable_class
    ::Partner
  end
end
