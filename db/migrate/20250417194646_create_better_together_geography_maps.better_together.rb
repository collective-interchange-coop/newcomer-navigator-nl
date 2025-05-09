# frozen_string_literal: true

# This migration comes from better_together (originally 20250321194847)
# Add table to store map data
class CreateBetterTogetherGeographyMaps < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :better_together_geography_maps

    create_bt_table :maps, prefix: :better_together_geography, id: :uuid do |t|
      t.bt_creator
      t.bt_identifier
      t.bt_locale
      t.bt_privacy
      t.bt_protected
    end
  end

  def down
    return unless table_exists? :better_together_geography_maps

    drop_table :better_together_geography_maps
  end
end
