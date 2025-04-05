# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def parameter_missing(error)
    render json: {
      error: 'Missing required parameter',
      parameter: error.param.to_s
    }, status: :bad_request
  end
end
