class RetryReceiptExtractionJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    Review::ReceiptReviewService.new(receipt:, actor: nil).retry_extraction!(reason: "background_retry")
  end
end

