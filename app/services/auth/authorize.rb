module Auth
  class Authorize
    prepend SimpleCommand

    def initialize(headers)
      @access_token = headers['authorization']&.split('Bearer ')&.last
    end

    def call
      validate_access_token
      Jwt::Decode.call(access_token).result
    end

    private

    def validate_access_token
      raise Exceptions::InvalidTokenError.new if access_token.blank?
    end

    attr_reader :access_token
  end
end
