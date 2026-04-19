module Review
  class ReviewQueueService
    def initialize(receipt:)
      @receipt = receipt
    end

    def enqueue!(reason_codes:)
      item = receipt.review_queue_item || receipt.build_review_queue_item(organization: receipt.organization)
      item.update!(
        state: :pending,
        resolved_at: nil,
        reason_codes_jsonb: Array(reason_codes).uniq
      )
      receipt.update!(status: :needs_review)

      Audit::AuditLogService.record!(
        event_type: "receipt.review_queued",
        organization: receipt.organization,
        auditable: receipt,
        after: {
          review_queue_item_id: item.id,
          reason_codes: item.reason_codes_jsonb
        }
      )

      item
    end

    def resolve!(actor: nil)
      return unless receipt.review_queue_item

      receipt.review_queue_item.update!(state: :resolved, resolved_at: Time.current)
      Audit::AuditLogService.record!(
        event_type: "receipt.review_resolved",
        organization: receipt.organization,
        auditable: receipt,
        actor:,
        after: { review_queue_item_id: receipt.review_queue_item.id }
      )
    end

    private

    attr_reader :receipt
  end
end

