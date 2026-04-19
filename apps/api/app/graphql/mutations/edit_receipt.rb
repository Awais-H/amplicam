module Mutations
  class EditReceipt < Types::BaseMutation
    argument :receipt_id, ID, required: true
    argument :merchant_name, String, required: false
    argument :receipt_date, GraphQL::Types::ISO8601Date, required: false
    argument :subtotal_amount, Types::Scalars::DecimalType, required: false
    argument :tax_amount, Types::Scalars::DecimalType, required: false
    argument :tip_amount, Types::Scalars::DecimalType, required: false
    argument :service_charge_amount, Types::Scalars::DecimalType, required: false
    argument :total_amount, Types::Scalars::DecimalType, required: false
    argument :category_code, String, required: false
    argument :comment, String, required: false

    field :receipt, Types::ReceiptType, null: false

    def resolve(receipt_id:, **attributes)
      comment = attributes.delete(:comment)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :update?)

      updated_receipt = Review::ReceiptReviewService.new(receipt:, actor: current_user).edit!(
        attributes:,
        comment:
      )

      { receipt: updated_receipt }
    end
  end
end

