module Auth
  class OmniauthUserUpserter
    def initialize(auth_hash:)
      @auth_hash = auth_hash
    end

    def call
      email = info["email"].presence || raise(ArgumentError, "OAuth response did not include an email")
      uid = auth_hash.fetch("uid")
      provider = auth_hash.fetch("provider")

      user = User.find_or_initialize_by(email: email.downcase)
      user.display_name = info["name"].presence || email.split("@").first
      user.avatar_url = info["image"]
      user.last_seen_at = Time.current
      user.save!(validate: false)

      user.oauth_identities.find_or_initialize_by(provider:, provider_uid: uid).tap do |identity|
        identity.email = email
        identity.token_metadata_jsonb = auth_hash["credentials"] || {}
        identity.save!
      end

      ensure_membership!(user)

      user
    end

    private

    attr_reader :auth_hash

    def info
      auth_hash.fetch("info", {})
    end

    def ensure_membership!(user)
      return if user.memberships.exists?

      organization = Organization.create!(
        name: "#{user.display_name}'s Workspace",
        slug: SecureRandom.hex(8),
        base_currency: "USD",
        timezone: "UTC"
      )
      Membership.create!(organization:, user:, role: :admin)
    end
  end
end
