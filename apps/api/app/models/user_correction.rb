class UserCorrection < ApplicationRecord
  belongs_to :receipt
  belongs_to :actor, class_name: "User"
  belongs_to :supersedes_correction, class_name: "UserCorrection", optional: true

  validates :corrected_fields_jsonb, presence: true
end

