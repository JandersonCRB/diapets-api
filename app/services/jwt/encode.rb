module Jwt
  class Encode
    prepend SimpleCommand
    include Helpers::EnvHelpers

    def initialize(payload)
      @payload = payload
    end

    def call
      JWT.encode(payload, jwt_secret, 'HS256')
    end

    private

    attr_reader :payload
  end
end