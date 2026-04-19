module Types
  class AuditEventType < BaseObject
    field :id, ID, null: false
    field :event_type, String, null: false
    field :action_source, String, null: false
    field :actor_display, String, null: true
    field :before, Types::Scalars::JsonType, null: true, method: :before_jsonb
    field :after, Types::Scalars::JsonType, null: false, method: :after_jsonb
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def actor_display
      object.actor&.display_name
    end
  end
end

