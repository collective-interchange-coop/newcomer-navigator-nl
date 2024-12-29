# frozen_string_literal: true

class Resource::DocumentPolicy < ResourcePolicy # rubocop:todo Style/Documentation
  def download?
    true
  end

  class Scope < ResourcePolicy::Scope
  end
end
