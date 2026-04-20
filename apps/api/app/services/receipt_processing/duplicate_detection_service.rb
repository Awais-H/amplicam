module ReceiptProcessing
  class DuplicateDetectionService
    def initialize(receipt:, normalization:)
      @receipt = receipt
      @normalization = normalization
    end

    def call
      exact_match = receipt.organization.receipts.where.not(id: receipt.id).find_by(file_checksum: receipt.file_checksum)
      fuzzy_key = [
        normalization.merchant_normalized,
        normalization.total_amount_cents,
        normalization.receipt_date
      ].join("|")

      fuzzy_match = receipt.organization.receipts
        .joins(:current_normalization)
        .where.not(id: receipt.id)
        .find_by(receipt_normalizations: {
          merchant_normalized: normalization.merchant_normalized,
          total_amount_cents: normalization.total_amount_cents,
          receipt_date: normalization.receipt_date
        })

      fingerprint = receipt.duplicate_fingerprint || receipt.build_duplicate_fingerprint
      fingerprint.update!(
        exact_checksum: receipt.file_checksum,
        merchant_total_date_fingerprint: fuzzy_key,
        matched_receipt: exact_match || fuzzy_match,
        match_score: exact_match ? 1.0 : (fuzzy_match ? 0.92 : 0.0),
        match_type: exact_match ? :exact : (fuzzy_match ? :fuzzy : :no_match)
      )

      Audit::AuditLogService.record!(
        event_type: "receipt.duplicate_checked",
        organization: receipt.organization,
        auditable: receipt,
        after: {
          duplicate_fingerprint_id: fingerprint.id,
          match_type: fingerprint.match_type,
          matched_receipt_id: fingerprint.matched_receipt_id
        }
      )

      fingerprint
    end

    private

    attr_reader :receipt, :normalization
  end
end

