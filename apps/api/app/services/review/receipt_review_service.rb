module Review
  class ReceiptReviewService
    EDITABLE_FIELDS = %i[
      merchant_name
      receipt_date
      subtotal_amount
      tax_amount
      tip_amount
      service_charge_amount
      total_amount
      category_code
    ].freeze

    def initialize(receipt:, actor:)
      @receipt = receipt
      @actor = actor
    end

    def edit!(attributes:, comment: nil)
      current_normalization = receipt.current_normalization || latest_normalization!
      normalized_changes = normalize_changes(attributes)
      before = normalization_snapshot(current_normalization)
      correction_payload = normalized_changes.presence || (comment.present? ? { comment_only: true } : nil)

      raise ArgumentError, "No changes provided" unless correction_payload

      Receipt.transaction do
        receipt.user_corrections.create!(
          actor:,
          corrected_fields_jsonb: correction_payload,
          comment:
        )

        new_normalization = receipt.receipt_normalizations.create!(
          processing_run: latest_processing_run!,
          merchant_name: normalized_changes.fetch(:merchant_name, current_normalization.merchant_name),
          merchant_normalized: Support::MerchantNormalizer.normalize(normalized_changes.fetch(:merchant_name, current_normalization.merchant_name)),
          receipt_date: normalized_changes.fetch(:receipt_date, current_normalization.receipt_date),
          currency: current_normalization.currency,
          subtotal_amount_cents: normalized_changes.fetch(:subtotal_amount_cents, current_normalization.subtotal_amount_cents),
          tax_amount_cents: normalized_changes.fetch(:tax_amount_cents, current_normalization.tax_amount_cents),
          tip_amount_cents: normalized_changes.fetch(:tip_amount_cents, current_normalization.tip_amount_cents),
          service_charge_amount_cents: normalized_changes.fetch(:service_charge_amount_cents, current_normalization.service_charge_amount_cents),
          total_amount_cents: normalized_changes.fetch(:total_amount_cents, current_normalization.total_amount_cents),
          payment_method_last4: current_normalization.payment_method_last4,
          location_jsonb: current_normalization.location_jsonb,
          line_items_jsonb: current_normalization.line_items_jsonb,
          reconciliation_status: current_normalization.reconciliation_status,
          reconciliation_delta_cents: current_normalization.reconciliation_delta_cents,
          confidence_breakdown_jsonb: current_normalization.confidence_breakdown_jsonb
        )

        receipt.update!(current_normalization: new_normalization, status: :needs_review)

        if normalized_changes[:category_code].present?
          receipt.category_decisions.create!(
            category_code: normalized_changes[:category_code],
            decision_source: "reviewer",
            confidence_score: 1.0,
            category_reason: "Reviewer override",
            reason_codes_jsonb: ["reviewer_override"]
          )
        end

        Audit::AuditLogService.record!(
          event_type: "receipt.edited",
          organization: receipt.organization,
          auditable: receipt,
          actor:,
          before:,
          after: normalized_changes
        )
      end

      receipt.reload
    end

    def approve!(comment: nil)
      if comment.present?
        receipt.user_corrections.create!(
          actor:,
          corrected_fields_jsonb: { approval_comment: true },
          comment:
        )
      end

      entry = Accounting::AccountingEntryService.new(
        receipt:,
        normalization: receipt.current_normalization || latest_normalization!,
        category_decision: receipt.category_decisions.order(created_at: :desc).first || fallback_category_decision!,
        actor:
      ).create_posted_entry!

      Review::ReviewQueueService.new(receipt:).resolve!(actor:)
      receipt.update!(status: :posted)
      entry
    end

    def reject!(reason:)
      Receipt.transaction do
        Review::ReviewQueueService.new(receipt:).resolve!(actor:)
        receipt.update!(status: :rejected)
        Audit::AuditLogService.record!(
          event_type: "receipt.rejected",
          organization: receipt.organization,
          auditable: receipt,
          actor:,
          after: { reason: }
        )
      end

      receipt
    end

    def mark_duplicate!(duplicate_of:)
      Receipt.transaction do
        Review::ReviewQueueService.new(receipt:).resolve!(actor:)
        receipt.update!(status: :duplicate, duplicate_of_receipt: duplicate_of)
        receipt.duplicate_fingerprint&.update!(matched_receipt: duplicate_of, match_type: :exact, match_score: 1.0)
        Audit::AuditLogService.record!(
          event_type: "receipt.duplicate_marked",
          organization: receipt.organization,
          auditable: receipt,
          actor:,
          after: { duplicate_of_receipt_id: duplicate_of.id }
        )
      end

      receipt
    end

    def retry_extraction!(reason: nil)
      run = receipt.processing_runs.create!(run_kind: :retry, status: :queued, job_id: "pending")
      job = ProcessReceiptJob.perform_later(receipt.id, run.id)
      run.update!(job_id: job.job_id)
      receipt.update!(status: :processing, current_processing_run: run)

      Audit::AuditLogService.record!(
        event_type: "receipt.retry_requested",
        organization: receipt.organization,
        auditable: receipt,
        actor:,
        after: { processing_run_id: run.id, reason: }
      )

      receipt
    end

    def split!(splits:, comment: nil)
      receipt.user_corrections.create!(
        actor:,
        corrected_fields_jsonb: { splits: },
        comment:
      )
      Audit::AuditLogService.record!(
        event_type: "receipt.split_requested",
        organization: receipt.organization,
        auditable: receipt,
        actor:,
        after: { splits: }
      )
      receipt.update!(status: :needs_review)
      receipt
    end

    private

    attr_reader :receipt, :actor

    def normalize_changes(attributes)
      attributes.symbolize_keys.slice(*EDITABLE_FIELDS).each_with_object({}) do |(key, value), result|
        next if value.nil?

        result[key] = value
        if key.to_s.end_with?("_amount")
          result["#{key}_cents".to_sym] = Support::Money.to_cents(value)
          result.delete(key)
        end
      end
    end

    def normalization_snapshot(normalization)
      {
        merchant_name: normalization.merchant_name,
        receipt_date: normalization.receipt_date,
        subtotal_amount_cents: normalization.subtotal_amount_cents,
        tax_amount_cents: normalization.tax_amount_cents,
        tip_amount_cents: normalization.tip_amount_cents,
        service_charge_amount_cents: normalization.service_charge_amount_cents,
        total_amount_cents: normalization.total_amount_cents
      }
    end

    def latest_processing_run!
      receipt.current_processing_run || receipt.processing_runs.order(created_at: :desc).first || receipt.processing_runs.create!(run_kind: :reprocess, status: :succeeded, job_id: "manual")
    end

    def latest_normalization!
      receipt.receipt_normalizations.order(created_at: :desc).first || receipt.receipt_normalizations.create!(
        processing_run: latest_processing_run!,
        currency: receipt.organization.base_currency
      )
    end

    def fallback_category_decision!
      receipt.category_decisions.create!(
        category_code: "uncategorized_review_required",
        decision_source: "reviewer",
        confidence_score: 1.0,
        category_reason: "Fallback reviewer category",
        reason_codes_jsonb: ["fallback_category"]
      )
    end
  end
end
