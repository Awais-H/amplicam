class AuditEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :auditable, polymorphic: true
  belongs_to :actor, class_name: "User", optional: true

  validates :event_type, :action_source, :after_jsonb, presence: true
end

