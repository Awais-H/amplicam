module ReceiptProcessing
  class DecisionEngine
    def initialize(receipt:, normalization:, category_decision:, confidence_result:, actor: nil)
      @receipt = receipt
      @normalization = normalization
      @category_decision = category_decision
      @confidence_result = confidence_result
      @actor = actor
    end

    def call
      if auto_post?
        Accounting::AccountingEntryService.new(
          receipt:,
          normalization:,
          category_decision:,
          actor:
        ).create_posted_entry!
      else
        Review::ReviewQueueService.new(receipt:).enqueue!(reason_codes: confidence_result.reason_codes.presence || ["review_required"])
      end
    end

    private

    attr_reader :receipt, :normalization, :category_decision, :confidence_result, :actor

    def auto_post?
      receipt.organization.conservative_auto_post? &&
        confidence_result.score >= receipt.organization.auto_post_threshold.to_f &&
        !confidence_result.hard_blocker &&
        normalization.currency == receipt.organization.base_currency &&
        normalization.reconciliation_status != "unreconciled"
    end
  end
end

