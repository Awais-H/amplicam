module Types
  class ReviewReasonCodeEnum < BaseEnum
    value "LOW_IMAGE_QUALITY", value: "low_image_quality"
    value "UNRECONCILED_TOTALS", value: "unreconciled_totals"
    value "HANDWRITTEN_TIP", value: "handwritten_tip"
    value "DUPLICATE_SUSPECTED", value: "duplicate_suspected"
    value "FOREIGN_CURRENCY", value: "foreign_currency"
    value "PARTIAL_RECEIPT", value: "partial_receipt"
    value "LOW_CATEGORY_CONFIDENCE", value: "low_category_confidence"
    value "POLICY_BLOCKED", value: "policy_blocked"
    value "PROCESSING_FAILED", value: "processing_failed"
  end
end

