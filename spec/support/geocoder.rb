# frozen_string_literal: true

# Configure Geocoder to use the test lookup during specs to avoid
# external HTTP calls and flakiness from background geocoding jobs.
require 'geocoder'

RSpec.configure do |config|
  config.before(:suite) do
    Geocoder.configure(
      lookup: :test,
      ip_lookup: :test,
      timeout: 1
    )

    # Provide a sane default stub for any query string.
    Geocoder::Lookup::Test.set_default_stub([
      {
        'latitude' => 45.5017,
        'longitude' => -73.5673,
        'coordinates' => [45.5017, -73.5673],
        'address' => 'Test Address',
        'state' => 'QC',
        'state_code' => 'QC',
        'country' => 'Canada',
        'country_code' => 'CA',
        'postal_code' => 'H2Y 1C6'
      }
    ])
  end
end

