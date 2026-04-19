module Types
  class QueryType < BaseObject
    field :current_user, Types::UserType, null: true
    field :current_organization, Types::OrganizationType, null: true
    field :receipt, Types::ReceiptType, null: true do
      argument :id, ID, required: true
    end
    field :receipts, Types::ReceiptType.connection_type, null: false do
      argument :status, Types::ReceiptStatusEnum, required: false
    end
    field :review_queue, Types::ReviewQueueItemType.connection_type, null: false do
      argument :state, String, required: false
    end
    field :accounting_entry, Types::AccountingEntryType, null: true do
      argument :receipt_id, ID, required: true
    end
    field :audit_history, Types::AuditEventType.connection_type, null: false do
      argument :receipt_id, ID, required: true
    end
    field :category_taxonomy, [String], null: false
    field :organization_policies, Types::Scalars::JsonType, null: false

    def current_user
      context[:current_user]
    end

    def current_organization
      context[:current_organization]
    end

    def receipt(id:)
      record = current_organization.receipts.find(id)
      authorize_record!(record, :show?)
      record
    end

    def receipts(status: nil)
      scope = current_organization.receipts.order(created_at: :desc)
      scope = scope.where(status:) if status.present?
      scope
    end

    def review_queue(state: nil)
      scope = current_organization.review_queue_items.includes(:receipt).order(priority: :asc, created_at: :desc)
      scope = scope.where(state:) if state.present?
      scope
    end

    def accounting_entry(receipt_id:)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :show?)
      receipt.accounting_entry
    end

    def audit_history(receipt_id:)
      receipt = current_organization.receipts.find(receipt_id)
      authorize_record!(receipt, :show?)
      receipt.audit_events.order(created_at: :desc)
    end

    def category_taxonomy
      Classification::ExpenseClassificationService::CATEGORIES
    end

    def organization_policies
      {
        tax_policy: current_organization.tax_policy_jsonb,
        category_policy: current_organization.category_policy_jsonb,
        posting_mode: current_organization.posting_mode,
        auto_post_threshold: current_organization.auto_post_threshold.to_s
      }
    end

    private

    def authorize_record!(record, query)
      policy = Pundit.policy!(Auth::SessionContext.new(user: current_user, organization: current_organization), record)
      raise Pundit::NotAuthorizedError, "Not authorized to #{query} #{record}" unless policy.public_send(query)
    end
  end
end
