Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get "/health", to: "health#show"

  scope :auth do
    get "/:provider/callback", to: "auth/omniauth_callbacks#show"
    get "/failure", to: "auth/omniauth_callbacks#failure"
    delete "/logout", to: "auth/omniauth_callbacks#destroy"
  end
end

