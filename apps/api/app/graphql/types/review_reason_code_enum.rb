module Types
  class ReviewReasonCodeEnum < BaseEnum
    MAPPING = {
      "LOW_IMAGE_QUALITY" => "low_image_quality",
      "UNRECONCILED_TOTALS" => "unreconciled_totals",
      "HANDWRITTEN_TIP" => "handwritten_tip",
      "DUPLICATE_SUSPECTED" => "duplicate_suspected",
      "FOREIGN_CURRENCY" => "foreign_currency",
      "PARTIAL_RECEIPT" => "partial_receipt",
      "LOW_CATEGORY_CONFIDENCE" => "low_category_confidence",
      "POLICY_BLOCKED" => "policy_blocked",
      "PROCESSING_FAILED" => "processing_failed",
      "EXTRACTION_ATTEMPT_FAILED" => "extraction_attempt_failed",
      "MISSING_REQUIRED_FIELDS" => "missing_required_fields",
      "REVIEW_REQUIRED" => "review_required"
    }.freeze

    MAPPING.each do |graphql_name, internal_value|
      value graphql_name, value: internal_value
    end

    def self.allowed_values
      MAPPING.values
    end
  end
end

