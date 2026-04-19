module Ai
  class ReceiptExtractionPrompt
    VERSION = "2026-04-19.v1".freeze
    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are ReceiptExtractionAgent for a bookkeeping system.
      Extract only information that is visible in the receipt image or pages provided.
      Return valid JSON matching the supplied schema and nothing else.
      Use null for any field that is missing, unreadable, or ambiguous.
      Never invent subtotal, tax, tip, service charge, merchant, or date.
      Distinguish voluntary tip from mandatory service charge.
      Mark ambiguity flags when totals do not reconcile or when handwritten values appear.
      Provide short evidence references and a brief reasoning summary, but do not include chain-of-thought.
    PROMPT

    def self.build(organization:)
      <<~PROMPT
        #{SYSTEM_PROMPT}

        Organization policy context:
        - base currency: #{organization.base_currency}
        - posting mode: #{organization.posting_mode}
        - auto post threshold: #{organization.auto_post_threshold}

        Return candidate extracted data for downstream normalization and accounting review.
      PROMPT
    end

    def self.schema
      {
        type: "object",
        required: ["merchant_name", "currency", "ambiguity_flags", "line_items"],
        additionalProperties: false,
        properties: {
          merchant_name: { type: ["string", "null"] },
          receipt_date: { type: ["string", "null"], format: "date" },
          currency: { type: ["string", "null"] },
          subtotal: { type: ["number", "null"] },
          tax: { type: ["number", "null"] },
          tip: { type: ["number", "null"] },
          service_charge: { type: ["number", "null"] },
          total: { type: ["number", "null"] },
          payment_method_last4: { type: ["string", "null"] },
          location: {
            type: ["object", "null"],
            additionalProperties: false,
            properties: {
              city: { type: ["string", "null"] },
              region: { type: ["string", "null"] },
              country: { type: ["string", "null"] }
            }
          },
          receipt_type: {
            type: ["string", "null"],
            enum: [
              "restaurant",
              "travel",
              "office_supplies",
              "fuel",
              "lodging",
              "transportation",
              "software_service",
              "telecom",
              "shipping",
              "unknown",
              nil
            ]
          },
          category_candidate: { type: ["string", "null"] },
          reasoning_summary: { type: ["string", "null"] },
          model_confidence: { type: ["number", "null"] },
          line_items: {
            type: "array",
            items: {
              type: "object",
              additionalProperties: false,
              properties: {
                name: { type: ["string", "null"] },
                quantity: { type: ["number", "null"] },
                amount: { type: ["number", "null"] }
              }
            }
          },
          ambiguity_flags: {
            type: "object",
            additionalProperties: false,
            required: ["handwritten_tip", "tax_inclusive", "tip_inclusive", "partial_receipt", "low_quality_image"],
            properties: {
              handwritten_tip: { type: "boolean" },
              tax_inclusive: { type: "boolean" },
              tip_inclusive: { type: "boolean" },
              partial_receipt: { type: "boolean" },
              low_quality_image: { type: "boolean" }
            }
          }
        }
      }
    end
  end
end

