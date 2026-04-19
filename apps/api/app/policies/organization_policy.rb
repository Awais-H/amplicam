class OrganizationPolicy < ApplicationPolicy
  def show?
    same_organization?
  end

  def update?
    same_organization? && admin?
  end

  private

  def same_organization?
    context.organization.present? && context.organization.id == record.id
  end
end

