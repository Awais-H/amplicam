module Auth
  class OmniauthCallbacksController < ApplicationController
    def show
      user = Auth::OmniauthUserUpserter.new(auth_hash: request.env["omniauth.auth"]).call
      fragment = Rack::Utils.build_query(
        {
          access_token: Auth::JsonWebToken.encode(user),
          token_type: "Bearer",
          expires_in: Auth::JsonWebToken.expiry_seconds.to_s
        }
      )
      frontend = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
      redirect_to "#{frontend}/login##{fragment}", allow_other_host: true
    rescue ArgumentError => e
      failure_redirect(e.message)
    end

    def failure
      failure_redirect(params[:message].presence || "OAuth sign in failed")
    end

    private

    def failure_redirect(message)
      frontend = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
      q = Rack::Utils.build_query({ auth_error: message })
      redirect_to "#{frontend}/login?#{q}", allow_other_host: true
    end
  end
end
