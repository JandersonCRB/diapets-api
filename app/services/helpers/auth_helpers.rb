module Helpers
  module AuthHelpers
    def generate_token(user)
      Jwt::Encode.call({ user_id: user.id }).result
    end

    def jwt_secret
      secret = ENV.fetch('JWT_SECRET', nil)

      raise Exceptions::InternalServerError.new("JWT_SECRET ENV VARIABLE NOT SET") if secret.nil?

      secret
    end
  end
end