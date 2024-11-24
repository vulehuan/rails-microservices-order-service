class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from CanCan::AccessDenied, with: :access_denied

  before_action :authenticate_request

  private

  def current_ability
    @current_ability ||= Ability.new(@current_user_role, @current_user_id)
  end

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last

    if token
      begin
        payload = JWT.decode(token, ENV['JWT_KEY'], true, algorithm: 'HS256')
        @current_user_role = payload[0]['role']
        @current_user_id = payload[0]['id']
      rescue JWT::DecodeError => e
        render json: { error: 'Invalid or expired token', message: e.message }, status: :unauthorized
      end
    else
      render json: { error: 'Token not provided' }, status: :unauthorized
    end
  end

  def handle_error(exception)
    # SendErrorToSentryJob.perform_later(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"
    logger.error "Backtrace: #{exception.backtrace.join("\n")}" if Rails.env.development? || Rails.env.test?

    render json: { error: "An unexpected error occurred" }, status: :internal_server_error
  end

  def record_not_found(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"

    render json: { error: "Record not found" }, status: :not_found
  end

  def record_invalid(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"

    render json: { error: "Invalid record" }, status: :unprocessable_entity
  end

  def access_denied(exception)
    Sentry.capture_exception(exception)
    logger.error "Error: #{exception.message}"

    render json: { error: "Access Denied" }, status: :forbidden
  end
end
