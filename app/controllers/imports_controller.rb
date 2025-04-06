# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :uploaded_file, only: %i[create]

  def create
    logs = import_from_file

    render json: { logs: logs, status: 'success' }, status: :ok
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

  def uploaded_file
    @file = params.require(:file)
  end
end
