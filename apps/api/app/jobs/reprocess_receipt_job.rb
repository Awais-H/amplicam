class ReprocessReceiptJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    run = receipt.processing_runs.create!(run_kind: :reprocess, status: :queued, job_id: job_id)
    ReceiptProcessing::ProcessReceipt.new(receipt:, processing_run: run).call
  end
end

