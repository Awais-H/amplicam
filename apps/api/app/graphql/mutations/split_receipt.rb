module Mutations
  class SplitReceipt < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :splits, Types::Scalars::JsonType, required: true
    argument :comment, String, required: false

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:, splits:, comment: nil)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :update?)
      Review::ReceiptReviewService.new(receipt:, actor: current_user).split!(splits:, comment:)
      { receipt: receipt.reload }
    end
  end
end

