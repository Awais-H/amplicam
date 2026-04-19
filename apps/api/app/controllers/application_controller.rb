class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
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

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_unauthorized
    render json: { error: "Authentication required" }, status: :unauthorized
  end

  def render_forbidden(error)
    render json: { error: error.message }, status: :forbidden
  end
end

