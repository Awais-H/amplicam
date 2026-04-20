# Browser PUTs Active Storage direct-upload URLs to the API (e.g. :3100) while Next.js
# runs on :3000 — cross-origin; CORS is required for OPTIONS preflight and PUT.
if Rails.env.development? || ENV["CORS_ORIGINS"].present?
  allowed_origins =
    if ENV["CORS_ORIGINS"].present?
      ENV["CORS_ORIGINS"].split(",").map(&:strip).compact_blank
    else
      %w[http://localhost:3000 http://127.0.0.1:3000]
    end

  unless allowed_origins.empty?
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins(*allowed_origins)

        resource "/storage/*",
          headers: :any,
          methods: %i[get put post head options],
          max_age: 600

        resource "/rails/active_storage/*",
          headers: :any,
          methods: %i[get put post head options],
          max_age: 600

        resource "/graphql",
          headers: :any,
          methods: %i[post options],
          credentials: true,
          max_age: 600

        resource "/auth/*",
          headers: :any,
          methods: %i[get post delete options],
          credentials: true,
          max_age: 600
      end
    end
  end
end
