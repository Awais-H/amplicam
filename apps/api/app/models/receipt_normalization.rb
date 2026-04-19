class ReceiptNormalization < ApplicationRecord
  belongs_to :receipt
  belongs_to :processing_run

  enum :reconciliation_status, {
    pending: "pending",
    reconciled: "reconciled",
    included_tax: "included_tax",
    included_tip: "included_tip",
    unreconciled: "unreconciled"
  }, default: :pending

  validates :currency, presence: true, length: { is: 3 }
end

