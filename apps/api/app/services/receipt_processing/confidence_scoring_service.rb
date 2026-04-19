module ReceiptProcessing
  class ConfidenceScoringService
    Result = Struct.new(:score, :reason_codes, :hard_blocker, keyword_init: true)

    def initialize(receipt:, extraction:, normalization:, category_decision:, duplicate_fingerprint:)
      @receipt = receipt
      @extraction = extraction
      @normalization = normalization
      @category_decision = category_decision
      @duplicate_fingerprint = duplicate_fingerprint
    end

    def call
      reasons = []
      score = 0.0

      completeness = normalization.receipt_date.present? && normalization.total_amount_cents.present? && normalization.merchant_name.present?
      score += completeness ? 0.25 : 0.05
      reasons << "missing_required_fields" unless completeness

      reconciled = normalization.reconciliation_status != "unreconciled"
      score += reconciled ? 0.25 : 0.0
      reasons << "unreconciled_totals" unless reconciled

      ambiguity_flags = extraction.parsed_fields.fetch("ambiguity_flags", {})
      quality_ok = !ambiguity_flags["low_quality_image"]
      score += quality_ok ? 0.15 : 0.05
      reasons << "low_image_quality" unless quality_ok

      score += category_decision.confidence_score.to_f >= 0.8 ? 0.15 : 0.05
      reasons << "low_category_confidence" if category_decision.confidence_score.to_f < 0.8

      duplicate_ok = duplicate_fingerprint.match_type == "none"
      score += duplicate_ok ? 0.10 : 0.0
      reasons << "duplicate_suspected" unless duplicate_ok

      policy_ok = normalization.currency == receipt.organization.base_currency
      score += policy_ok ? 0.10 : 0.0
      reasons << "foreign_currency" unless policy_ok

      reasons << "handwritten_tip" if ambiguity_flags["handwritten_tip"]
      reasons << "partial_receipt" if ambiguity_flags["partial_receipt"]

      hard_blocker = reasons.any? { |code| %w[unreconciled_totals duplicate_suspected handwritten_tip partial_receipt].include?(code) }

      Result.new(
        score: score.round(3),
        reason_codes: reasons.uniq,
        hard_blocker:
      )
    end

    private

    attr_reader :receipt, :extraction, :normalization, :category_decision, :duplicate_fingerprint
  end
end

