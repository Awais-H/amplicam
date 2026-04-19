module Auth
  class OmniauthCallbacksController < ApplicationController
    def show
      auth_hash = request.env["omniauth.auth"]
      user = Auth::OidcUserUpserter.new(auth_hash: auth_hash).call

      session[:user_id] = user.id
      session[:organization_id] = user.memberships.first&.organization_id

      render json: {
        authenticated: true,
        user_id: user.id,
        organization_id: session[:organization_id]
      }
    end

    def destroy
      reset_session
      head :no_content
    end

    def failure
      render json: { error: params[:message] || "OAuth sign in failed" }, status: :unauthorized
    end
  end
end

