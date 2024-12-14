class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_errors
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  private

  def handle_validation_errors(exception)
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  def handle_record_not_found(exception)
    render json: { message: "#{exception.model.to_s.titleize} not found" }, status: :not_found
  end
end
