# This migration comes from better_together (originally 20241025144852)
class RemoveMessagesContentColumnNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :better_together_messages, :content, true
  end
end
