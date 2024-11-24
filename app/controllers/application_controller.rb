class ApplicationController < ActionController::API
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
end
