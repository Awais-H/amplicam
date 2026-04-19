class HealthController < ApplicationController
  def show
    render json: { ok: true, service: "bookkeeper-agent-api", timestamp: Time.current.iso8601 }
  end
end

