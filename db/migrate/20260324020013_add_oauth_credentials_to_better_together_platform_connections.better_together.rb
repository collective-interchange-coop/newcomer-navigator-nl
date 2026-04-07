# frozen_string_literal: true

# This migration comes from better_together (originally 20260313003000)
class AddOauthCredentialsToBetterTogetherPlatformConnections < ActiveRecord::Migration[7.2]
  def change
    # Guard: create_platform_connections already includes oauth_client_id and its unique
    # index on fresh installs (CE 0.10.1+). Skip if present.
    unless column_exists?(:better_together_platform_connections, :oauth_client_id)
      change_table :better_together_platform_connections, bulk: true do |t|
        t.string :oauth_client_id
        t.text :oauth_client_secret
      end
    end
    unless index_name_exists?(:better_together_platform_connections,
                              'index_bt_platform_connections_on_oauth_client_id')
      add_index :better_together_platform_connections,
                :oauth_client_id,
                unique: true,
                name: 'index_bt_platform_connections_on_oauth_client_id'
    end
  end
end
