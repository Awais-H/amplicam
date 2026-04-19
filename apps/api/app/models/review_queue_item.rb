class ReviewQueueItem < ApplicationRecord
  belongs_to :organization
  belongs_to :receipt
  belongs_to :assigned_to, class_name: "User", optional: true

  enum :state, {
    pending: "pending",
    in_review: "in_review",
    resolved: "resolved"
  }, default: :pending

  validates :reason_codes_jsonb, presence: true
end

