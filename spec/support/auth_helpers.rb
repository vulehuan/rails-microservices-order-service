module AuthHelpers
  def jwt_token_for(role, user_id)
    payload = { role: role, user_id: user_id }
    JWT.encode(payload, ENV['JWT_KEY'], 'HS256')
  end
end

RSpec.configure do |config|
  config.include AuthHelpers
end
