class ReceiptPolicy < ApplicationPolicy
  def show?
    same_organization? && (reviewer? || owner?)
  end

  def create?
    context.user.present? && context.organization.present? && submitter?
  end

  def update?
    same_organization? && (reviewer? || owner?)
  end

  def approve?
    update?
  end

  def retry_extraction?
    update?
  end

  private

  def same_organization?
    context.organization.present? && record.organization_id == context.organization.id
  end

  def owner?
    record.respond_to?(:uploaded_by_id) && record.uploaded_by_id == context.user&.id
  end
end

