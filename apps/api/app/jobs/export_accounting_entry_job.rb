class ExportAccountingEntryJob < ApplicationJob
  queue_as :low

  def perform(accounting_entry_id, adapter_key)
    entry = AccountingEntry.find(accounting_entry_id)
    adapter = Accounting::LedgerAdapter.fetch!(adapter_key).new

    adapter.validate(entry)
    payload = adapter.serialize(entry)
    external_ref = adapter.publish(entry)

    entry.update!(
      status: :exported,
      export_state: "published",
      export_payload_jsonb: {
        adapter_key:,
        payload:,
        external_ref:
      }
    )
  end
end

