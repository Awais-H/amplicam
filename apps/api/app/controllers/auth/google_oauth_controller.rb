module Auth
  class GoogleOauthController < ApplicationController
    # Only reached when OmniAuth is not handling this path (Google client not configured).
    def show
      msg = "Google sign-in is not configured on the API. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET."
      frontend = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
      q = Rack::Utils.build_query({ auth_error: msg })
      redirect_to "#{frontend}/login?#{q}", allow_other_host: true
    end
  end
end
