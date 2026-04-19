Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :openid_connect,
    name: :oidc,
    scope: %i[openid email profile],
    response_type: :code,
    issuer: ENV["OIDC_ISSUER"],
    discovery: true,
    client_auth_method: :basic,
    client_options: {
      identifier: ENV["OIDC_CLIENT_ID"],
      secret: ENV["OIDC_CLIENT_SECRET"],
      redirect_uri: "#{ENV.fetch("APP_HOST", "http://localhost:3000")}/auth/oidc/callback"
    }
  )
end

