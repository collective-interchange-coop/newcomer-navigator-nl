# frozen_string_literal: true

# This migration comes from better_together (originally 20250328133728)
# Add support for Single Table Inheritance to allow different types of roles.
class AddTypeToBetterTogetherRoles < ActiveRecord::Migration[7.1]
  def change
    change_table :better_together_roles do |t|
      t.string :type, null: false, default: 'BetterTogether::Role'
    end
  end
end
