class Receipt < ApplicationRecord
  belongs_to :organization
  belongs_to :uploaded_by, class_name: "User"
  belongs_to :duplicate_of_receipt, class_name: "Receipt", optional: true
  belongs_to :current_processing_run, class_name: "ProcessingRun", optional: true
  belongs_to :current_extraction, class_name: "ReceiptExtraction", optional: true
  belongs_to :current_normalization, class_name: "ReceiptNormalization", optional: true
  has_one_attached :source_file

  has_many :processing_runs, dependent: :restrict_with_exception
  has_many :receipt_extractions, dependent: :restrict_with_exception
  has_many :receipt_normalizations, dependent: :restrict_with_exception
  has_many :category_decisions, dependent: :restrict_with_exception
  has_many :audit_events, as: :auditable, dependent: :restrict_with_exception
  has_many :user_corrections, dependent: :restrict_with_exception
  has_one :review_queue_item, dependent: :restrict_with_exception
  has_one :duplicate_fingerprint, dependent: :restrict_with_exception
  has_one :accounting_entry, dependent: :restrict_with_exception

  enum :status, {
    uploaded: "uploaded",
    processing: "processing",
    needs_review: "needs_review",
    approved: "approved",
    posted: "posted",
    duplicate: "duplicate",
    rejected: "rejected",
    failed: "failed"
  }, default: :uploaded

  validates :status, presence: true
  validates :organization, :uploaded_by, presence: true
  validates :mime_type, inclusion: { in: ["image/jpeg", "image/png", "image/heic", "application/pdf"], allow_blank: true }

  def review_required?
    needs_review? || review_queue_item.present?
  end
end

