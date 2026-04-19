class ProcessReceiptJob < ApplicationJob
  queue_as :default

  retry_on Faraday::TimeoutError, wait: :exponentially_longer, attempts: 3

  def perform(receipt_id, processing_run_id)
    receipt = Receipt.find(receipt_id)
    processing_run = receipt.processing_runs.find(processing_run_id)

    ReceiptProcessing::ProcessReceipt.new(
      receipt:,
      processing_run:
    ).call
  end
end

