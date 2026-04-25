require "active_support/core_ext/integer/time"

Rails.application.configure do
  required_env = %w[DATABASE_URL SECRET_KEY_BASE]
  missing = required_env.select { |name| ENV[name].to_s.strip.empty? }
  if missing.any?
    raise "Missing required production environment variables: #{missing.join(', ')}"
  end

  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.active_storage.service = :amazon
  config.active_support.deprecation = :notify
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.active_record.dump_schema_after_migration = false
end
