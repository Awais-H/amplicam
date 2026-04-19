class AccountingEntry < ApplicationRecord
  belongs_to :organization
  belongs_to :receipt

  has_many :accounting_entry_lines, dependent: :destroy
  has_many :audit_events, as: :auditable, dependent: :restrict_with_exception

  enum :status, {
    draft: "draft",
    posted: "posted",
    exported: "exported",
    failed: "failed"
  }, default: :draft

  validates :transaction_date, :currency, :gross_amount_cents, :source_provenance_jsonb, presence: true
end
