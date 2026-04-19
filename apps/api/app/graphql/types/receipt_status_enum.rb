module Types
  class ReceiptStatusEnum < BaseEnum
    value "UPLOADED", value: "uploaded"
    value "PROCESSING", value: "processing"
    value "NEEDS_REVIEW", value: "needs_review"
    value "APPROVED", value: "approved"
    value "POSTED", value: "posted"
    value "DUPLICATE", value: "duplicate"
    value "REJECTED", value: "rejected"
    value "FAILED", value: "failed"
  end
end

