configured_service = ENV["ACTIVE_STORAGE_SERVICE"].to_s.strip
Rails.application.config.active_storage.service = configured_service.to_sym if configured_service.present?
Rails.application.config.active_storage.variant_processor = :vips
Rails.application.config.active_storage.routes_prefix = "/storage"
