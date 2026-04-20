Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get "/health", to: "health#show"

  # Only when Google credentials are missing: OmniAuth is not mounted, so this avoids a
  # routing error and redirects to the frontend with a clear message. When credentials
  # are set, OmniAuth owns GET /auth/google_oauth2 — do not register a duplicate route.
  google_oauth_configured =
    ENV.fetch("GOOGLE_CLIENT_ID", "").strip.present? && ENV.fetch("GOOGLE_CLIENT_SECRET", "").strip.present?
  unless google_oauth_configured
    get "/auth/google_oauth2", to: "auth/google_oauth#show"
  end

  scope :auth do
    post "/login", to: "auth/sessions#create"
    post "/register", to: "auth/registrations#create"
    get "/me", to: "auth/sessions#show"
    delete "/logout", to: "auth/sessions#destroy"
    get "/failure", to: "auth/omniauth_callbacks#failure"
    get "/:provider/callback", to: "auth/omniauth_callbacks#show"
  end
end
