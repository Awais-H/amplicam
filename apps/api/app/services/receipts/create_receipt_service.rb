module Receipts
  class CreateReceiptService
    def initialize(organization:, actor:)
      @organization = organization
      @actor = actor
    end

    def call(blob_signed_id:, source: nil)
      blob = ActiveStorage::Blob.find_signed!(blob_signed_id)

      receipt = organization.receipts.create!(
        uploaded_by: actor,
        mime_type: blob.content_type,
        file_checksum: blob.checksum,
        received_at: Time.current
      )
      receipt.source_file.attach(blob)

      Audit::AuditLogService.record!(
        event_type: "receipt.created",
        organization:,
        auditable: receipt,
        actor:,
        after: {
          receipt_id: receipt.id,
          source:,
          filename: blob.filename.to_s,
          byte_size: blob.byte_size
        }
      )

      run = receipt.processing_runs.create!(run_kind: :initial, status: :queued, job_id: "pending")
      job = ProcessReceiptJob.perform_later(receipt.id, run.id)
      run.update!(job_id: job.job_id)
      receipt.update!(status: :processing, current_processing_run: run)

      receipt
    end

    private

    attr_reader :organization, :actor
  end
end

