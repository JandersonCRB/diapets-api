module Jwt
  class Decode
    prepend SimpleCommand
    include Helpers::EnvHelpers

    def initialize(token, verify: true)
      @token = token
      @verify = verify
    end

    def call
      decoded = JWT.decode(token, jwt_secret, verify, { algorithm: 'HS256' })[0]
      raise Exceptions::InvalidTokenError.new, 'Invalid Token' if decoded.blank?
      decoded.symbolize_keys
    rescue JWT::VerificationError, JWT::DecodeError => e
      raise Exceptions::InvalidTokenError.new, 'Invalid Token' if decoded.blank?
    end

    private

    attr_reader :token, :verify
  end
end
