class AccountingEntry < ApplicationRecord
  belongs_to :organization
  belongs_to :receipt

  has_many :accounting_entry_lines, dependent: :destroy

  enum :status, {
    draft: "draft",
    posted: "posted",
    exported: "exported",
    failed: "failed"
  }, default: :draft

  validates :transaction_date, :currency, :gross_amount_cents, :source_provenance_jsonb, presence: true
end

