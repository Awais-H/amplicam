module Mutations
  class RetryReceiptExtraction < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :reason, String, required: false

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:, reason: nil)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :retry_extraction?)
      Review::ReceiptReviewService.new(receipt:, actor: current_user).retry_extraction!(reason:)
      { receipt: receipt.reload }
    end
  end
end

