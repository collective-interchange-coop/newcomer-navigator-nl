# frozen_string_literal: true

# rubocop:todo Style/Documentation
class Resource::Document < Resource # rubocop:todo Style/ClassAndModuleChildren, Style/Documentation
  # rubocop:enable Style/Documentation
  MAX_FILE_SIZE_MB = ENV.fetch('MAX_FILE_SIZE_MB', 10).to_i.megabytes

  has_one_attached :file
  validates :file, presence: true, attached: true, size: { less_than: MAX_FILE_SIZE_MB }

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def self.extra_permitted_attributes
    super + %i[
      file
    ]
  end
end
