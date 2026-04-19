module Mutations
  class ExportAccountingEntry < Types::BaseMutation
    argument :entry_id, ID, required: true
    argument :adapter_key, String, required: true

    field :accounting_entry, Types::AccountingEntryType, null: false

    def resolve(entry_id:, adapter_key:)
      entry = current_organization.accounting_entries.find(entry_id)
      authorize_record!(entry, :export?)
      ExportAccountingEntryJob.perform_later(entry.id, adapter_key)
      { accounting_entry: entry }
    end
  end
end

