module Helpers
  module EnvHelpers
    def jwt_secret
      jwt = ENV.fetch('JWT_SECRET', nil)
      raise Exceptions::InternalServerError.new("JWT_SECRET ENV VARIABLE NOT SET") if jwt.nil?
      jwt
    end
  end
end
