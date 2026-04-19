module Mutations
  class CreateAccountingEntry < Types::BaseMutation
    argument :receipt_id, ID, required: true

    field :accounting_entry, Types::AccountingEntryType, null: false

    def resolve(receipt_id:)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :approve?)
      entry = Accounting::AccountingEntryService.new(
        receipt:,
        normalization: receipt.current_normalization || receipt.receipt_normalizations.order(created_at: :desc).first,
        category_decision: receipt.category_decisions.order(created_at: :desc).first,
        actor: current_user
      ).create_posted_entry!
      { accounting_entry: entry }
    end
  end
end

