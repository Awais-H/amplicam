class ReceiptExtraction < ApplicationRecord
  belongs_to :receipt
  belongs_to :processing_run

  validates :extraction_model, :prompt_version, :raw_model_output, :parsed_fields, presence: true
end

