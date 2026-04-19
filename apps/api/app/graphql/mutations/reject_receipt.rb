module Mutations
  class RejectReceipt < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :reason, String, required: true

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:, reason:)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :update?)
      Review::ReceiptReviewService.new(receipt:, actor: current_user).reject!(reason:)
      { receipt: receipt.reload }
    end
  end
end

