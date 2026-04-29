Rails.application.config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym
Rails.application.config.active_storage.variant_processor = :vips
Rails.application.config.active_storage.routes_prefix = "/storage"

