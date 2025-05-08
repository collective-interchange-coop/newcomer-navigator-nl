# frozen_string_literal: true

# This migration comes from better_together (originally 20250227163308)
class CreateBetterTogetherMetricsPageViewReports < ActiveRecord::Migration[7.1]
  def change
    return if table_exists? :better_together_metrics_page_view_reports

    create_bt_table :page_view_reports, prefix: :better_together_metrics do |t|
      t.jsonb   :filters,             null: false, default: {}
      t.boolean :sort_by_total_views, null: false, default: false
      t.string  :file_format,         null: false, default: 'csv'
      t.jsonb   :report_data,         null: false, default: {}
    end

    add_index :better_together_metrics_page_view_reports, :filters, using: :gin
  end
end
