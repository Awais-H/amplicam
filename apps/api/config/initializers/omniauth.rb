# OmniAuth request phase: GET is convenient for local dev; prefer POST + CSRF in production.
unless Rails.env.production?
  OmniAuth.config.allowed_request_methods = %i[get post]
end

OmniAuth.config.logger = Rails.logger

google_ready = ENV["GOOGLE_CLIENT_ID"].to_s.strip.present? && ENV["GOOGLE_CLIENT_SECRET"].to_s.strip.present?
oidc_ready = ENV["OIDC_ISSUER"].present? && ENV["OIDC_CLIENT_ID"].present? && ENV["OIDC_CLIENT_SECRET"].present?

if google_ready || oidc_ready
  # Public origin of this API (no trailing slash). Must match Google Cloud "Authorized redirect URIs"
  # host, e.g. APP_HOST=http://localhost:3100 → redirect URI .../auth/google_oauth2/callback
  app_origin = ENV.fetch("APP_HOST", "http://localhost:3100").sub(%r{/+\z}, "")
  OmniAuth.config.full_host = app_origin

  Rails.application.config.middleware.use OmniAuth::Builder do
    if google_ready
      provider(
        :google_oauth2,
        ENV.fetch("GOOGLE_CLIENT_ID"),
        ENV.fetch("GOOGLE_CLIENT_SECRET"),
        scope: "email,profile,openid",
        prompt: "select_account",
        access_type: "online"
      )
    end

    if oidc_ready
      provider(
        :openid_connect,
        name: :oidc,
        scope: %i[openid email profile],
        response_type: :code,
        issuer: ENV.fetch("OIDC_ISSUER"),
        discovery: true,
        client_auth_method: :basic,
        client_options: {
          identifier: ENV.fetch("OIDC_CLIENT_ID"),
          secret: ENV.fetch("OIDC_CLIENT_SECRET"),
          redirect_uri: "#{ENV.fetch('APP_HOST', 'http://localhost:3100')}/auth/oidc/callback"
        }
      )
    end
  end
end
