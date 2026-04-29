module Types
  class ReviewQueueItemType < BaseObject
    field :id, ID, null: false
    field :state, String, null: false
    field :reasons, [Types::ReviewReasonCodeEnum], null: false
    field :receipt, Types::ReceiptType, null: false
    field :assigned_to, Types::UserType, null: true
    field :priority, Integer, null: false
    field :locked_at, GraphQL::Types::ISO8601DateTime, null: true
    field :resolved_at, GraphQL::Types::ISO8601DateTime, null: true

    def reasons
      object.reason_codes_jsonb
    end
  end
end

