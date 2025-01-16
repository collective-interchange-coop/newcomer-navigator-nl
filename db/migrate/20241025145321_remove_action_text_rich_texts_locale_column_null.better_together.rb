# frozen_string_literal: true

# This migration comes from better_together (originally 20241025145238)
class RemoveActionTextRichTextsLocaleColumnNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :action_text_rich_texts, :locale, true
  end
end
