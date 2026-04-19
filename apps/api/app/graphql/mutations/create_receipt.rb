module Mutations
  class CreateReceipt < Types::BaseMutation
    argument :blob_signed_id, String, required: true
    argument :source, String, required: false

    field :receipt, Types::ReceiptType, null: false

    def resolve(blob_signed_id:, source: nil)
      authorize_record!(Receipt, :create?)

      receipt = Receipts::CreateReceiptService.new(
        organization: current_organization,
        actor: current_user
      ).call(blob_signed_id:, source:)

      { receipt: }
    end
  end
end

