class AccountingEntryLine < ApplicationRecord
  belongs_to :accounting_entry

  enum :line_type, {
    expense: "expense",
    tax: "tax",
    tip: "tip",
    service_charge: "service_charge",
    rounding: "rounding"
  }

  validates :line_type, :account_code, :amount_cents, presence: true
end

