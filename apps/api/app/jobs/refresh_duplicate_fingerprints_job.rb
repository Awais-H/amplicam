class RefreshDuplicateFingerprintsJob < ApplicationJob
  queue_as :low

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    normalization = receipt.current_normalization || receipt.receipt_normalizations.order(created_at: :desc).first
    return unless normalization

    ReceiptProcessing::DuplicateDetectionService.new(receipt:, normalization:).call
  end
end

