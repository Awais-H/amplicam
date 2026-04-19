module Auth
  class OidcUserUpserter
    def initialize(auth_hash:)
      @auth_hash = auth_hash
    end

    def call
      info = auth_hash.fetch("info", {})
      uid = auth_hash.fetch("uid")
      provider = auth_hash.fetch("provider")

      user = User.find_or_initialize_by(email: info.fetch("email"))
      user.display_name = info["name"].presence || info["email"].split("@").first
      user.avatar_url = info["image"]
      user.last_seen_at = Time.current
      user.save!

      user.oauth_identities.find_or_initialize_by(provider:, provider_uid: uid).tap do |identity|
        identity.email = info["email"]
        identity.token_metadata_jsonb = auth_hash["credentials"] || {}
        identity.save!
      end

      return user if user.memberships.exists?

      organization = Organization.create!(
        name: "#{user.display_name}'s Workspace",
        slug: SecureRandom.hex(8),
        base_currency: "USD",
        timezone: "UTC"
      )
      Membership.create!(organization:, user:, role: :admin)

      user
    end

    private

    attr_reader :auth_hash
  end
end

