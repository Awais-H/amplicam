require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module BookkeeperAgentApi
  class Application < Rails::Application
    config.load_defaults 8.0

    config.api_only = true
    config.time_zone = "UTC"
    config.active_job.queue_adapter = :solid_queue
    config.active_record.schema_format = :ruby
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec, fixture: false
      g.helper false
      g.assets false
    end

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
      key: "_bookkeeper_agent_session",
      secure: Rails.env.production?,
      same_site: :lax,
      httponly: true
  end
end

