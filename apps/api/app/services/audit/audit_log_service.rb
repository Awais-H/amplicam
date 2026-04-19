module Audit
  class AuditLogService
    def self.record!(event_type:, organization:, auditable:, after:, actor: nil, before: nil, action_source: nil, metadata: {})
      AuditEvent.create!(
        organization:,
        auditable:,
        actor:,
        event_type:,
        action_source: action_source || default_action_source(actor),
        before_jsonb: before,
        after_jsonb: after,
        metadata_jsonb: metadata
      )
    end

    def self.default_action_source(actor)
      actor.present? ? "user" : "system"
    end
    private_class_method :default_action_source
  end
end

