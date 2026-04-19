module Types
  class AccountingEntryLineType < BaseObject
    field :id, ID, null: false
    field :line_type, String, null: false
    field :account_code, String, null: false
    field :amount, Types::MoneyType, null: false
    field :metadata, Types::Scalars::JsonType, null: false, method: :metadata_jsonb

    def amount
      Support::Money.payload(cents: object.amount_cents, currency: object.accounting_entry.currency)
    end
  end
end

