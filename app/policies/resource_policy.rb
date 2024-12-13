# frozen_string_literal: true

class ResourcePolicy < ApplicationPolicy # rubocop:todo Style/Documentation
  def index?
    true
  end

  def new?
    create?
  end

  def show?
    true
  end

  def edit?
    update?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def create?
    user.present? && user.permitted_to?('manage_platform')
  end

  class Scope < ApplicationPolicy::Scope
  end
end
