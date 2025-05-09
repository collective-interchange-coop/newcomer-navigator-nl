# frozen_string_literal: true

namespace :nn_nl do # rubocop:todo Metrics/BlockLength
  desc 'Migrate Partner Addresses to Buildings'
  task migrate_partner_buildings: :environment do # rubocop:todo Metrics/BlockLength
    Mobility.with_locale(:en) do
      partners = Partner.joins(:addresses).includes(:buildings)
                        .where.not(addresses: { line1: nil })
                        .where(buildings: { address_id: nil })
      new_buildings = []

      Partner.transaction do
        partners.each do |partner|
          next if partner.buildings.any?

          partner.addresses.each do |addr|
            name = addr.geocoding_string

            building = new_buildings.find { |building| building.name == name }

            building ||= BetterTogether::Infrastructure::Building.i18n.find_by(name:)

            unless building
              building = BetterTogether::Infrastructure::Building.create(
                address_id: addr.id,
                creator_id: partner.creator_id,
                privacy: addr.privacy,
                name:
              )

              new_buildings << building
            end

            partner.building_connections.create(building: building)

            addr.contact_detail_id = nil

            addr.save

            puts "Added new building to #{partner} for address: #{addr.geocoding_string}"
          end
        end
      end
    end
  end
end
