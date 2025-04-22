# frozen_string_literal: true

class Partner < BetterTogether::Community # rubocop:todo Style/Documentation
  include BetterTogether::Searchable
  include NewToNlJourneyStage
  include NewToNlTopic

  has_many_journey_stages
  has_many_topics

  settings index: default_elasticsearch_index

  # Customize the data sent to Elasticsearch for indexing
  def as_indexed_json(_options = {})
    as_json(
      only: [:id],
      methods: [:name, :slug, *self.class.localized_attribute_list.keep_if do |a|
      a.starts_with?('name') || a.starts_with?('slug') || (a.starts_with?('description') && !a.starts_with?('description_html'))
      end],
      include: self.class.localized_attribute_list.keep_if { |a| a.starts_with?('description_html') }.index_with do |attribute|
        {
          only: [:id],
          methods: [:to_plain_text]
        }
      end
    )
  end
end
