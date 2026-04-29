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
  configured_storage_service = ENV["ACTIVE_STORAGE_SERVICE"].to_s.strip
  aws_storage_env = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_S3_BUCKET]
  aws_storage_ready = aws_storage_env.all? { |name| ENV[name].to_s.strip.present? }

  config.active_storage.service =
    if configured_storage_service.present?
      configured_storage_service.to_sym
    elsif aws_storage_ready
      :amazon
    else
      :local
    end
  config.active_support.deprecation = :notify
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.active_record.dump_schema_after_migration = false
end
