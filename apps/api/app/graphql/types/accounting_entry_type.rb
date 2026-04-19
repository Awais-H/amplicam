module Types
  class AccountingEntryType < BaseObject
    field :id, ID, null: false
    field :status, String, null: false
    field :transaction_date, GraphQL::Types::ISO8601Date, null: false
    field :merchant_name, String, null: true
    field :gross, Types::MoneyType, null: false
    field :lines, [Types::AccountingEntryLineType], null: false
    field :source_provenance, Types::Scalars::JsonType, null: false, method: :source_provenance_jsonb

    def gross
      Support::Money.payload(cents: object.gross_amount_cents, currency: object.currency)
    end
  end
end

