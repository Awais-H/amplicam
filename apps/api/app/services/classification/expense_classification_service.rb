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

    # Maps extraction schema receipt_type -> internal category_code
    RECEIPT_TYPE_TO_CATEGORY = {
      "restaurant" => "meals_and_entertainment",
      "travel" => "travel_transportation",
      "office_supplies" => "office_supplies",
      "fuel" => "fuel",
      "lodging" => "lodging",
      "transportation" => "travel_transportation",
      "software_service" => "software_subscriptions",
      "telecom" => "telecom_internet",
      "shipping" => "shipping_and_courier"
    }.freeze

    def initialize(receipt:, normalization:, extraction:)
      @receipt = receipt
      @normalization = normalization
      @extraction = extraction
    end

    def call
      candidate = rules_category
      source = candidate ? "rules" : nil

      unless candidate
        candidate = model_candidate
        source = "model_assist" if candidate
      end

      unless candidate
        candidate = receipt_type_category
        source = "receipt_type" if candidate
      end

      unless candidate
        candidate = heuristic_fallback_category
        source = "heuristic_default" if candidate
      end

      candidate ||= "uncategorized_review_required"
      source ||= "default"

      confidence = confidence_for(source, candidate)

      decision = receipt.category_decisions.create!(
        category_code: candidate,
        decision_source: source,
        confidence_score: confidence,
        category_reason: reason_for(source, candidate),
        reason_codes_jsonb: [source]
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
      line_text = normalization.line_items_jsonb.map { |item| item["name"] || item[:name] }.join(" ")
      haystack = [
        normalization.merchant_name,
        normalization.merchant_normalized,
        line_text,
        extraction.parsed_fields["receipt_type"]
      ].compact_blank.join(" ").downcase

      return "meals_and_entertainment" if haystack.match?(/restaurant|grill|cafe|coffee|pizza|burger|meal|dinner/)
      return "travel_transportation" if haystack.match?(/uber|lyft|taxi|cab|train|metro|rideshare/)
      return "parking_and_tolls" if haystack.match?(/parking|toll/)
      return "office_supplies" if haystack.match?(/staples|office|printer|paper|stationery/)
      return "office_supplies" if haystack.match?(/home\s*depot|\blowes\b|lowe's|menards|ace hardware/)
      return "fuel" if haystack.match?(/fuel|shell|exxon|chevron|gasoline|pump|octane/)
      return "lodging" if haystack.match?(/hotel|inn|folio|room rate|lodging/)
      return "software_subscriptions" if haystack.match?(/software|subscription|license|saas|plan/)
      return "telecom_internet" if haystack.match?(/telecom|internet|wireless|mobile|phone/)
      return "shipping_and_courier" if haystack.match?(/shipping|courier|postage|fedex|ups|dhl/)
      return "professional_services" if haystack.match?(/\b(legal|attorney|cpa|accounting|consulting)\b/)
      return "miscellaneous_expense" if haystack.match?(/\b(walmart|target|amazon|costco|kroger|safeway)\b/)
    end

    def model_candidate
      candidate = extraction.parsed_fields["category_candidate"]
      candidate if CATEGORIES.include?(candidate)
    end

    def receipt_type_category
      rt = extraction.parsed_fields["receipt_type"]
      return unless rt.is_a?(String)

      if rt == "unknown"
        return "miscellaneous_expense" if meaningful_receipt_signal?

        return
      end

      RECEIPT_TYPE_TO_CATEGORY[rt]
    end

    def heuristic_fallback_category
      return "miscellaneous_expense" if meaningful_receipt_signal?

      nil
    end

    def meaningful_receipt_signal?
      normalization.merchant_name.present? ||
        normalization.merchant_normalized.present? ||
        normalization.total_amount_cents.to_i.positive? ||
        line_items?
    end

    def line_items?
      items = extraction.parsed_fields["line_items"]
      items.is_a?(Array) && items.any?
    end

    def confidence_for(source, candidate)
      return 0.42 if candidate == "uncategorized_review_required"

      case source
      when "rules" then 0.9
      when "model_assist" then 0.84
      when "receipt_type" then 0.72
      when "heuristic_default" then 0.58
      else 0.65
      end
    end

    def reason_for(source, candidate)
      return "Needs manual category — insufficient signals on the receipt." if candidate == "uncategorized_review_required"

      case source
      when "rules" then "Matched from merchant, line items, or receipt type keywords."
      when "model_assist" then "Suggested by the extraction model (category_candidate)."
      when "receipt_type" then "Inferred from the model's receipt_type field."
      when "heuristic_default" then "Default general expense — some receipt detail was present without a closer match."
      else "Assigned automatically for downstream review or posting."
      end
    end
  end
end

