# frozen_string_literal: true

# rubocop:todo Style/Documentation
class Resource::Link < Resource # rubocop:todo Style/ClassAndModuleChildren, Style/Documentation
  # rubocop:enable Style/Documentation
  validates :url, presence: true

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def self.extra_permitted_attributes
    super + %i[
      url
    ]
  end
end
