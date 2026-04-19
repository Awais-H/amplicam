module Classification
  class ExpenseClassificationService
    CATEGORIES = %w[
      meals_and_entertainment
      travel_transportation
      lodging
      office_supplies
      software_subscriptions
      telecom_internet
      fuel
      parking_and_tolls
      shipping_and_courier
      professional_services
      miscellaneous_expense
      uncategorized_review_required
    ].freeze

    def initialize(receipt:, normalization:, extraction:)
      @receipt = receipt
      @normalization = normalization
      @extraction = extraction
    end

    def call
      candidate = rules_category
      decision_source = candidate ? "rules" : "model_assist"
      candidate ||= model_candidate
      candidate ||= "uncategorized_review_required"

      confidence = candidate == "uncategorized_review_required" ? 0.45 : 0.85

      decision = receipt.category_decisions.create!(
        category_code: candidate,
        decision_source:,
        confidence_score: confidence,
        category_reason: reason_for(candidate),
        reason_codes_jsonb: [decision_source]
      )

      Audit::AuditLogService.record!(
        event_type: "receipt.categorized",
        organization: receipt.organization,
        auditable: receipt,
        after: {
          category_decision_id: decision.id,
          category_code: decision.category_code,
          decision_source: decision.decision_source
        }
      )

      decision
    end

    private

    attr_reader :receipt, :normalization, :extraction

    def rules_category
      haystack = [
        normalization.merchant_normalized,
        normalization.line_items_jsonb.map { |item| item["name"] || item[:name] }.join(" "),
        extraction.parsed_fields["receipt_type"]
      ].compact.join(" ").downcase

      return "meals_and_entertainment" if haystack.match?(/restaurant|grill|cafe|coffee|pizza|burger|meal|dinner/)
      return "travel_transportation" if haystack.match?(/uber|lyft|taxi|cab|train|metro|rideshare/)
      return "parking_and_tolls" if haystack.match?(/parking|toll/)
      return "office_supplies" if haystack.match?(/staples|office|printer|paper|stationery/)
      return "fuel" if haystack.match?(/fuel|shell|exxon|chevron|gasoline|pump|octane/)
      return "lodging" if haystack.match?(/hotel|inn|folio|room rate|lodging/)
      return "software_subscriptions" if haystack.match?(/software|subscription|license|saas|plan/)
      return "telecom_internet" if haystack.match?(/telecom|internet|wireless|mobile|phone/)
      return "shipping_and_courier" if haystack.match?(/shipping|courier|postage|fedex|ups|dhl/)
    end

    def model_candidate
      candidate = extraction.parsed_fields["category_candidate"]
      candidate if CATEGORIES.include?(candidate)
    end

    def reason_for(candidate)
      "Matched by keyword and receipt context" unless candidate == "uncategorized_review_required"
    end
  end
end

