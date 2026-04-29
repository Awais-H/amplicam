require "uri"

class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # Disk direct-upload URLs must be absolute and reachable from the browser (not Docker
  # internal hostnames). Next.js proxies GraphQL to this API on localhost:3100 by default.
  before_action :set_active_storage_public_urls, if: :local_disk_active_storage?

  def current_user
    @current_user ||= user_from_session || user_from_jwt
  end

  def current_organization
    return unless current_user

    @current_organization ||= begin
      org_id = session[:organization_id] || current_user.memberships.first&.organization_id
      current_user.organizations.find_by(id: org_id)
    end
  end

  def authenticate_user!
    render_unauthorized unless current_user
  end

  def pundit_user
    Auth::SessionContext.new(user: current_user, organization: current_organization)
  end

  private

  def local_disk_active_storage?
    Rails.env.development? && Rails.application.config.active_storage.service == :local
  end

  def set_active_storage_public_urls
    uri = URI.parse(ENV.fetch("RAILS_PUBLIC_URL", "http://localhost:3000"))
    opts = { host: uri.host, protocol: uri.scheme || "http" }
    opts[:port] = uri.port if uri.port && !((uri.scheme == "http" && uri.port == 80) || (uri.scheme == "https" && uri.port == 443))
    ActiveStorage::Current.url_options = opts
  rescue URI::InvalidURIError
    nil
  end

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_unauthorized
    render json: { error: "Authentication required" }, status: :unauthorized
  end

  def render_forbidden(error)
    render json: { error: error.message }, status: :forbidden
  end

  def user_from_session
    User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def user_from_jwt
    header = request.headers["Authorization"].to_s
    return unless header.start_with?("Bearer ")

    token = header.delete_prefix("Bearer ").strip
    payload = Auth::JsonWebToken.decode(token)
    return unless payload

    User.find_by(id: payload["sub"])
  end

  def auth_token_bundle(user)
    {
      access_token: Auth::JsonWebToken.encode(user),
      token_type: "Bearer",
      expires_in: Auth::JsonWebToken.expiry_seconds,
      user: user_payload(user)
    }
  end

  def user_payload(user)
    {
      id: user.id,
      email: user.email,
      display_name: user.display_name,
      avatar_url: user.avatar_url
    }
  end
end
