# frozen_string_literal: true

class Partner < BetterTogether::Community # rubocop:todo Style/Documentation
  include BetterTogether::Searchable
  include NewToNlJourneyStage
  include NewToNlTopic

  has_many_journey_stages
  has_many_topics

  settings index: default_elasticsearch_index

  # Customize the data sent to Elasticsearch for indexing
  def as_indexed_json(_options = {}) # rubocop:todo Metrics/MethodLength
    localized_attributes = self.class.localized_attribute_list
    filtered_methods = localized_attributes.select do |a|
      a.starts_with?('name') || a.starts_with?('slug') ||
        (a.starts_with?('description') && !a.starts_with?('description_html'))
    end

    filtered_includes = {}
    localized_attributes.each do |a|
      next unless a.starts_with?('description_html')

      filtered_includes[a] = {
        only: [:id],
        methods: [:to_plain_text]
      }
    end

    as_json(
      only: [:id],
      methods: [:name, :slug, *filtered_methods],
      include: filtered_includes
    )
  end
end
