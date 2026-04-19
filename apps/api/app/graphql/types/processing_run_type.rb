module Types
  class ProcessingRunType < BaseObject
    field :id, ID, null: false
    field :run_kind, String, null: false
    field :status, String, null: false
    field :error_class, String, null: true
    field :error_message, String, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :finished_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end

