# frozen_string_literal: true

# Custom collection map for partners
# This class is used to create a map of partners, which are collections of spaces
# and buildings. It inherits from PartnerMap and overrides the records method to
# return a collection of partners ordered by their creation date.
#
# @see PartnerMap
#
# @example
#   partner_map = PartnerCollectionMap.new
#   partner_map.records # => returns a collection of partners ordered by creation date
#
# @note This class is used for creating maps of partners in the application and rendered on the partners index view.
class PartnerCollectionMap < PartnerMap
  def self.records # rubocop:todo Metrics/MethodLength
    mappable_class
      .includes(
        # Deep eager loading matching the actual association path
        {
          buildings: [
            # GeospatialSpace -> Space for coordinates (matches joins path)
            {
              geospatial_space: :space
            },
            # Address for leaflet_points address formatting (no translations)
            :address
          ]
        },
        # Partner name translations needed for leaflet point labels
        :string_translations
      )
      .joins(buildings: [:geospatial_space, { geospatial_space: :space }])
      .order(created_at: :desc)
  end

  # Override leaflet_points to precompute all data without triggering additional queries
  def leaflet_points
    @leaflet_points ||= calculate_leaflet_points
  end

  def records
    self.class.records
  end

  def spaces
    records.map(&:spaces).flatten.uniq
  end

  private

  # Precompute all leaflet points data using the already eager-loaded associations
  # rubocop:todo Metrics/PerceivedComplexity
  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/AbcSize
  def calculate_leaflet_points # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    records.flat_map do |partner|
      partner.buildings.filter_map do |building|
        # Use space through the preloaded geospatial_space -> space association path
        space = building.geospatial_space&.space
        next unless space&.geocoded?

        # Build point data using the preloaded associations
        point = {
          lat: space.latitude,
          lng: space.longitude,
          elevation: space.elevation
        }

        # Build labels using preloaded partner and address data
        place_label = if building.address&.text_label.present?
                        " - #{building.address.text_label}"
                      else
                        ''
                      end

        place_url = Rails.application.routes.url_helpers.polymorphic_path(
          partner,
          locale: I18n.locale
        )

        # rubocop:todo Layout/LineLength
        place_link = "<a href='#{place_url}' class='text-decoration-none'><strong>#{partner.name}#{place_label}</strong></a>"
        # rubocop:enable Layout/LineLength

        address_label = building.address&.to_formatted_s(excluded: [:display_label]) || ''

        point.merge(
          label: place_link,
          popup_html: place_link + "<br>#{address_label}"
        )
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
end
