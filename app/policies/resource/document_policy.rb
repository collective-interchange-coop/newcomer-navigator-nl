# frozen_string_literal: true

# rubocop:todo Style/Documentation
class Resource::DocumentPolicy < ResourcePolicy # rubocop:todo Style/ClassAndModuleChildren
  # rubocop:enable Style/Documentation
  def download?
    true
  end

  class Scope < ResourcePolicy::Scope
  end
end
