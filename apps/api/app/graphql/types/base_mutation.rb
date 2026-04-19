module Types
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class GraphQL::Schema::Argument
    field_class GraphQL::Schema::Field
    input_object_class GraphQL::Schema::InputObject
    object_class GraphQL::Schema::Object

    private

    def current_user
      context[:current_user]
    end

    def current_organization
      context[:current_organization]
    end
  end
end

