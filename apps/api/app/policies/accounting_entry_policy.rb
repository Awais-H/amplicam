class AccountingEntryPolicy < ApplicationPolicy
  def show?
    same_organization? && (reviewer? || owner?)
  end

  def export?
    same_organization? && admin?
  end

  private

  def same_organization?
    context.organization.present? && record.organization_id == context.organization.id
  end

  def owner?
    record.receipt.uploaded_by_id == context.user&.id
  end
end
