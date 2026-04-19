class DuplicateFingerprint < ApplicationRecord
  belongs_to :receipt
  belongs_to :matched_receipt, class_name: "Receipt", optional: true

  enum :match_type, {
    none: "none",
    exact: "exact",
    fuzzy: "fuzzy"
  }, default: :none
end

