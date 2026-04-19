class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, {
    admin: "admin",
    reviewer: "reviewer",
    submitter: "submitter"
  }, default: :submitter

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id }
end

