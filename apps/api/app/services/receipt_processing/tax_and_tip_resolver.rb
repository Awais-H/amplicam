module ReceiptProcessing
  class TaxAndTipResolver
    Result = Struct.new(:status, :delta_cents, :reason_codes, keyword_init: true)

    def initialize(subtotal_cents:, tax_cents:, tip_cents:, service_charge_cents:, total_cents:, tax_inclusive:, tip_inclusive:, tolerance_cents: 2)
      @subtotal_cents = subtotal_cents
      @tax_cents = tax_cents
      @tip_cents = tip_cents
      @service_charge_cents = service_charge_cents
      @total_cents = total_cents
      @tax_inclusive = tax_inclusive
      @tip_inclusive = tip_inclusive
      @tolerance_cents = tolerance_cents
    end

    def resolve
      return Result.new(status: "pending", delta_cents: nil, reason_codes: ["missing_total"]) if total_cents.nil?

      expected = subtotal_cents.to_i + tax_component + tip_component + service_charge_cents.to_i
      delta = total_cents.to_i - expected

      status =
        if delta.abs <= tolerance_cents
          if tax_inclusive
            "included_tax"
          elsif tip_inclusive
            "included_tip"
          else
            "reconciled"
          end
        else
          "unreconciled"
        end

      reason_codes = []
      reason_codes << "unreconciled_totals" if status == "unreconciled"
      reason_codes << "tax_inclusive" if tax_inclusive
      reason_codes << "tip_inclusive" if tip_inclusive

      Result.new(status:, delta_cents: delta, reason_codes:)
    end

    private

    attr_reader :subtotal_cents, :tax_cents, :tip_cents, :service_charge_cents, :total_cents, :tax_inclusive, :tip_inclusive, :tolerance_cents

    def tax_component
      tax_inclusive ? 0 : tax_cents.to_i
    end

    def tip_component
      tip_inclusive ? 0 : tip_cents.to_i
    end
  end
end

