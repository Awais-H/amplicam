module ReceiptProcessing
  class ReceiptNormalizationService
    def initialize(receipt:, extraction:, processing_run:)
      @receipt = receipt
      @extraction = extraction
      @processing_run = processing_run
    end

    def call
      payload = extraction.parsed_fields.with_indifferent_access
      currency = payload[:currency].presence || receipt.organization.base_currency

      resolver = TaxAndTipResolver.new(
        subtotal_cents: Support::Money.to_cents(payload[:subtotal]),
        tax_cents: Support::Money.to_cents(payload[:tax]),
        tip_cents: Support::Money.to_cents(payload[:tip]),
        service_charge_cents: Support::Money.to_cents(payload[:service_charge]),
        total_cents: Support::Money.to_cents(payload[:total]),
        tax_inclusive: payload.dig(:ambiguity_flags, :tax_inclusive),
        tip_inclusive: payload.dig(:ambiguity_flags, :tip_inclusive)
      ).resolve

      normalization = receipt.receipt_normalizations.create!(
        processing_run:,
        merchant_name: payload[:merchant_name],
        merchant_normalized: Support::MerchantNormalizer.normalize(payload[:merchant_name]),
        receipt_date: parse_date(payload[:receipt_date]),
        currency: currency.to_s.upcase,
        subtotal_amount_cents: Support::Money.to_cents(payload[:subtotal]),
        tax_amount_cents: Support::Money.to_cents(payload[:tax]),
        tip_amount_cents: Support::Money.to_cents(payload[:tip]),
        service_charge_amount_cents: Support::Money.to_cents(payload[:service_charge]),
        total_amount_cents: Support::Money.to_cents(payload[:total]),
        payment_method_last4: payload[:payment_method_last4],
        location_jsonb: payload[:location] || {},
        line_items_jsonb: payload[:line_items] || [],
        reconciliation_status: resolver.status,
        reconciliation_delta_cents: resolver.delta_cents,
        confidence_breakdown_jsonb: {
          arithmetic_reason_codes: resolver.reason_codes,
          ambiguity_flags: payload[:ambiguity_flags] || {}
        }
      )

      receipt.update!(current_normalization: normalization)

      Audit::AuditLogService.record!(
        event_type: "receipt.normalized",
        organization: receipt.organization,
        auditable: receipt,
        after: {
          normalization_id: normalization.id,
          reconciliation_status: normalization.reconciliation_status
        }
      )

      normalization
    end

    private

    attr_reader :receipt, :extraction, :processing_run

    def parse_date(value)
      return if value.blank?

      Date.iso8601(value)
    rescue ArgumentError
      nil
    end
  end
end

