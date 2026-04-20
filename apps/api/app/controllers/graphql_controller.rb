class GraphqlController < ApplicationController
  before_action :authenticate_user!

  # In development, allow GraphQL without a Bearer JWT or session (seeded demo user).
  # Set DISABLE_GRAPHQL_DEV_AUTH=1 to require Authorization: Bearer <jwt> or a session cookie.
  def current_user
    return super unless graphql_dev_auth_fallback?

    @current_user ||= super || User.find_by(email: "demo@example.com")
  end

  def execute
    result = BookkeeperAgentSchema.execute(
      params[:query],
      variables: ensure_hash(params[:variables]),
      context: {
        current_user: current_user,
        current_organization: current_organization,
        session: session
      },
      operation_name: params[:operationName]
    )

    render json: result
  rescue StandardError => error
    render json: { errors: [{ message: error.message }] }, status: :unprocessable_entity
  end

  private

  def graphql_dev_auth_fallback?
    Rails.env.development? && ENV["DISABLE_GRAPHQL_DEV_AUTH"] != "1"
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash, ActionController::Parameters
      ambiguous_param.to_unsafe_h
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables parameter"
    end
  end
end

