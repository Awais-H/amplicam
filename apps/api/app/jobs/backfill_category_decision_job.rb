class BackfillCategoryDecisionJob < ApplicationJob
  queue_as :low

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    normalization = receipt.current_normalization || receipt.receipt_normalizations.order(created_at: :desc).first
    extraction = receipt.current_extraction || receipt.receipt_extractions.order(created_at: :desc).first
    return unless normalization && extraction

    Classification::ExpenseClassificationService.new(receipt:, normalization:, extraction:).call
  end
end

