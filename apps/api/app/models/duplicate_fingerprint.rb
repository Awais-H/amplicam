class DuplicateFingerprint < ApplicationRecord
  belongs_to :receipt
  belongs_to :matched_receipt, class_name: "Receipt", optional: true

  # Key cannot be `none` — it conflicts with ActiveRecord::Querying#none.
  enum :match_type, {
    no_match: "none",
    exact: "exact",
    fuzzy: "fuzzy"
  }, default: :no_match
end

