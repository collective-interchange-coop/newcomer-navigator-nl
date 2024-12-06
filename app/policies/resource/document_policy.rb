# frozen_string_literal: true

module Resource
  class DocumentPolicy < ResourcePolicy # rubocop:todo Style/Documentation
    def download?
      true
    end

    class Scope < ResourcePolicy::Scope
    end
  end
end
