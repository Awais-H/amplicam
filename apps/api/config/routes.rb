Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get "/health", to: "health#show"

  scope :auth do
    post "/login", to: "auth/sessions#create"
    post "/register", to: "auth/registrations#create"
    get "/me", to: "auth/sessions#show"
    delete "/logout", to: "auth/sessions#destroy"
  end
end
