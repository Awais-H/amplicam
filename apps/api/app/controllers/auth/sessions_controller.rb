module Auth
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: %i[show destroy]

    def create
      email = params[:email].to_s.strip.downcase
      password = params[:password].to_s
      user = User.authenticate_by(email:, password:)
      unless user
        render json: { error: "Invalid email or password" }, status: :unauthorized
        return
      end

      user.update_column(:last_seen_at, Time.current)
      render json: auth_token_bundle(user)
    end

    def show
      render json: {
        user: user_payload(current_user),
        organization_id: current_organization&.id
      }
    end

    def destroy
      reset_session
      head :no_content
    end
  end
end
