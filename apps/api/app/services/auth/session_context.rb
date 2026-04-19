module Auth
  class SessionContext
    attr_reader :user, :organization

    def initialize(user:, organization:)
      @user = user
      @organization = organization
    end

    def membership
      return unless user && organization

      @membership ||= user.memberships.find_by(organization_id: organization.id)
    end

    def role
      membership&.role
    end
  end
end

