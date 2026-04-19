module Types
  class QueryType < BaseObject
    field :current_user, Types::UserType, null: true
    field :current_organization, Types::OrganizationType, null: true

    def current_user
      context[:current_user]
    end

    def current_organization
      context[:current_organization]
    end
  end
end

