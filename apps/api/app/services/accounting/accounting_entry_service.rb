module Accounting
  class AccountingEntryService
    def initialize(receipt:, normalization:, category_decision:, actor:)
      @receipt = receipt
      @normalization = normalization
      @category_decision = category_decision
      @actor = actor
    end

    def create_posted_entry!
      return receipt.accounting_entry if receipt.accounting_entry&.posted?

      AccountingEntry.transaction do
        entry = receipt.create_accounting_entry!(
          organization: receipt.organization,
          status: :posted,
          transaction_date: normalization.receipt_date || Date.current,
          currency: normalization.currency,
          gross_amount_cents: normalization.total_amount_cents || 0,
          subtotal_amount_cents: normalization.subtotal_amount_cents,
          tax_amount_cents: normalization.tax_amount_cents,
          tip_amount_cents: normalization.tip_amount_cents,
          service_charge_amount_cents: normalization.service_charge_amount_cents,
          merchant_name: normalization.merchant_normalized || normalization.merchant_name,
          category_code: category_decision.category_code,
          source_provenance_jsonb: provenance_payload
        )

        build_lines!(entry)

        receipt.update!(status: :posted)
        Review::ReviewQueueService.new(receipt:).resolve!(actor:) if receipt.review_queue_item.present?
        Audit::AuditLogService.record!(
          event_type: "accounting_entry.posted",
          organization: receipt.organization,
          auditable: entry,
          actor:,
          after: provenance_payload
        )
        entry
      end
    end

    private

    attr_reader :receipt, :normalization, :category_decision, :actor

    def build_lines!(entry)
      entry.accounting_entry_lines.create!(
        line_type: :expense,
        account_code: category_decision.category_code,
        amount_cents: normalization.subtotal_amount_cents || normalization.total_amount_cents || 0
      )
      create_optional_line(entry, :tax, "sales_tax_paid", normalization.tax_amount_cents)
      create_optional_line(entry, :tip, "expense_tip", normalization.tip_amount_cents)
      create_optional_line(entry, :service_charge, "service_charge", normalization.service_charge_amount_cents)
      create_optional_line(entry, :rounding, "rounding_adjustment", normalization.reconciliation_delta_cents) if normalization.reconciliation_delta_cents.to_i.abs <= 2 && normalization.reconciliation_delta_cents.to_i != 0
    end

    def create_optional_line(entry, type, code, amount_cents)
      return if amount_cents.blank? || amount_cents.to_i.zero?

      entry.accounting_entry_lines.create!(line_type: type, account_code: code, amount_cents:)
    end

    def provenance_payload
      {
        receipt_id: receipt.id,
        extraction_id: receipt.current_extraction_id,
        normalization_id: normalization.id,
        category_decision_id: category_decision.id,
        actor_id: actor&.id,
        prompt_version: receipt.current_extraction&.prompt_version,
        extraction_model: receipt.current_extraction&.extraction_model
      }
    end
  end
end

