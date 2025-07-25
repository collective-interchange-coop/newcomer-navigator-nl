# frozen_string_literal: true

class JourneyMap < BetterTogether::Content::Template # rubocop:todo Style/Documentation
  include NewToNlJourneyStage

  has_one_journey_stage(required: true)

  self.available_templates = %w[
    better_together/content/blocks/template/journey_map
  ].freeze

  # AVAILABLE_STAGES = %w[
  #   pre-arrival arrival settling
  # ].freeze

  has_many :page_blocks, class_name: 'BetterTogether::Content::PageBlock', foreign_key: :block_id, dependent: :destroy
  has_many :pages, through: :page_blocks

  delegate :topics, to: :journey_stage

  translates :heading, type: :string

  store_attributes :content_settings do
    heading_type String, default: 'h2'
  end

  store_attributes :layout_settings do
    heading_position String, default: 'left'
  end

  # validates :stage, inclusion: { in: ->(instance) { instance.class::AVAILABLE_STAGES }}

  def self.extra_permitted_attributes
    %i[journey_stage_id]
  end

  def initialize(args = nil)
    super

    self.template_path = 'better_together/content/blocks/template/journey_map'
  end

  def stage_colour
    case stage_identifier
    when 'pre-arrival'
      'green'
    when 'arrival'
      'teal'
    when 'settlement'
      'blue'
    else
      ''
    end
  end

  def stage_identifier
    journey_stage&.identifier
  end
end
