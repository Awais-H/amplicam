module Mutations
  class ApproveReceipt < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :comment, String, required: false

    field :receipt, Types::ReceiptType, null: false
    field :accounting_entry, Types::AccountingEntryType, null: false

    def resolve(receipt_id:, comment: nil)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :approve?)

      entry = Review::ReceiptReviewService.new(receipt:, actor: current_user).approve!(comment:)
      { receipt: receipt.reload, accounting_entry: entry }
    end
  end
end

