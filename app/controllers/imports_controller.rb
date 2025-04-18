# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :set_uploaded_file, only: %i[create]

  def create
    response = import_from_file

    return render json: { **response, status: 'Failed' }, status: :bad_request if response[:created_records].blank?

    return render json: { **response, status: 'Partially successful' }, status: :multi_status if response[:errors].any?

    render json: { **response, status: 'Success' }, status: :ok
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  rescue StandardError => e
    log_errors(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def import_from_file
    DataConversionTool::RestaurantImporter.import_from_file(@file.tempfile.path)
  end

  def log_errors(exception)
    Rails.logger.error(" ---> [X IMPORT ERROR] #{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n")) if exception.backtrace
  end

  def set_uploaded_file
    @file = params.require(:file)
  end
end
