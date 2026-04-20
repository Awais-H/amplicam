module Ai
  # Minimal stand-in for Gemini when GEMINI_API_KEY is unset in development (local Docker).
  class StubGeminiClient
    MODEL_NAME = "stub-development".freeze

    def extract_receipt!(image_parts:, organization:, model: MODEL_NAME)
      {
        extraction_model: model,
        raw_model_output: { "stub" => true, "image_parts_count" => image_parts.size },
        parsed_fields: stub_parsed_fields(organization),
        reasoning_summary: "Stub extraction: set GEMINI_API_KEY for real AI, or DISABLE_STUB_AI=1 to fail fast without a key.",
        model_confidence: 0.15,
        token_usage: {}
      }
    end

    private

    def stub_parsed_fields(organization)
      {
        "merchant_name" => "Sample Retailer (stub)",
        "receipt_date" => nil,
        "currency" => organization.base_currency,
        "subtotal" => 10.0,
        "tax" => 1.0,
        "tip" => nil,
        "service_charge" => nil,
        "total" => 11.0,
        "payment_method_last4" => nil,
        "location" => nil,
        "receipt_type" => "unknown",
        "category_candidate" => "miscellaneous_expense",
        "reasoning_summary" => "No model call (development stub).",
        "model_confidence" => 0.15,
        "line_items" => [],
        "ambiguity_flags" => {
          "handwritten_tip" => false,
          "tax_inclusive" => false,
          "tip_inclusive" => false,
          "partial_receipt" => true,
          "low_quality_image" => false
        }
      }
    end
  end
end
