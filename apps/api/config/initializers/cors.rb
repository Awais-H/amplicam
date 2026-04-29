# Browser PUTs Active Storage direct-upload URLs to the API while Next.js may run on a
# different origin. Keep storage CORS broad enough for Railway-hosted web apps, but keep
# authenticated API endpoints on the stricter allowlist.
if Rails.env.development? || Rails.env.production? || ENV["CORS_ORIGINS"].present?
  app_origins =
    if ENV["CORS_ORIGINS"].present?
      ENV["CORS_ORIGINS"].split(",").map(&:strip).compact_blank
    else
      %w[http://localhost:3000 http://127.0.0.1:3000]
    end

  storage_origins =
    if Rails.env.production?
      [
        /\Ahttps:\/\/.*\.railway\.app\z/,
        /\Ahttps:\/\/.*\.up\.railway\.app\z/
      ]
    else
      app_origins
    end

  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    if storage_origins.present?
      allow do
        origins(*storage_origins)

        resource "/storage/*",
          headers: :any,
          methods: %i[get put post head options],
          max_age: 600

        resource "/rails/active_storage/*",
          headers: :any,
          methods: %i[get put post head options],
          max_age: 600
      end
    end

    if app_origins.present?
      allow do
        origins(*app_origins)

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
