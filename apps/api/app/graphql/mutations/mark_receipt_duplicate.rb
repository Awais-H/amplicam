module Mutations
  class MarkReceiptDuplicate < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :duplicate_of_receipt_id, ID, required: true

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:, duplicate_of_receipt_id:)
      receipt = current_organization.receipts.find(receipt_id)
      duplicate_of = current_organization.receipts.find(duplicate_of_receipt_id)
      authorize_record!(receipt, :update?)
      Review::ReceiptReviewService.new(receipt:, actor: current_user).mark_duplicate!(duplicate_of:)
      { receipt: receipt.reload }
    end
  end
end

