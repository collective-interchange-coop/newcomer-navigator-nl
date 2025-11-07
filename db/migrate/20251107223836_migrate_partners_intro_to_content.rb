# frozen_string_literal: true

# Migrates Partners List Intro from YAML to RichText Content
class MigratePartnersIntroToContent < ActiveRecord::Migration[8.0]
  def up
    # Run the rake task to migrate partners intro content
    Rake::Task['nn_nl:migrate_partners_intro_to_content'].invoke
  end

  def down
    # Remove the created RichText content
    identifier = 'partners-list-intro'
    rich_text = BetterTogether::Content::RichText.find_by(identifier: identifier)
    rich_text&.destroy
  end
end
