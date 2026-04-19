class GraphqlController < ApplicationController
  before_action :authenticate_user!

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

