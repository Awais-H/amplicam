class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :receipts, dependent: :destroy
  has_many :review_queue_items, dependent: :destroy
  has_many :accounting_entries, dependent: :destroy
  has_many :audit_events, dependent: :destroy

  enum :posting_mode, {
    review_only: "review_only",
    conservative_auto_post: "conservative_auto_post"
  }, default: :review_only

  validates :name, :slug, :base_currency, :timezone, presence: true
  validates :slug, uniqueness: true
  validates :base_currency, length: { is: 3 }
  validates :auto_post_threshold, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
end

