module Mutations
  class StartReceiptExtraction < Types::BaseMutation
    argument :receipt_id, ID, required: true

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :retry_extraction?)
      Review::ReceiptReviewService.new(receipt:, actor: current_user).retry_extraction!(reason: "manual_start")
      { receipt: receipt.reload }
    end
  end
end

