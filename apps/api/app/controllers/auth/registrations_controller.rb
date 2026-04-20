module Auth
  class RegistrationsController < ApplicationController
    def create
      p = registration_params
      email = p[:email].to_s.strip.downcase
      user = User.new(
        email:,
        password: p[:password],
        password_confirmation: p[:password_confirmation].presence || p[:password],
        display_name: p[:display_name].presence || email.split("@").first
      )
      user.registering_with_password = true
      if user.save
        ensure_membership!(user)
        render json: auth_token_bundle(user), status: :created
      else
        render json: { error: "Validation failed", details: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def registration_params
      params.permit(:email, :password, :password_confirmation, :display_name)
    end

    def ensure_membership!(user)
      return if user.memberships.exists?

      organization = Organization.create!(
        name: "#{user.display_name.presence || user.email.split('@').first}'s Workspace",
        slug: SecureRandom.hex(8),
        base_currency: "USD",
        timezone: "UTC"
      )
      Membership.create!(organization:, user:, role: :admin)
    end

  end
end
