module Types
  class MutationType < BaseObject
    field :initiate_receipt_upload, mutation: Mutations::InitiateReceiptUpload
    field :create_receipt, mutation: Mutations::CreateReceipt
    field :start_receipt_extraction, mutation: Mutations::StartReceiptExtraction
    field :edit_receipt, mutation: Mutations::EditReceipt
    field :approve_receipt, mutation: Mutations::ApproveReceipt
    field :split_receipt, mutation: Mutations::SplitReceipt
    field :reject_receipt, mutation: Mutations::RejectReceipt
    field :mark_receipt_duplicate, mutation: Mutations::MarkReceiptDuplicate
    field :retry_receipt_extraction, mutation: Mutations::RetryReceiptExtraction
    field :create_accounting_entry, mutation: Mutations::CreateAccountingEntry
    field :export_accounting_entry, mutation: Mutations::ExportAccountingEntry
    field :update_organization_policies, mutation: Mutations::UpdateOrganizationPolicies
  end
end
