# frozen_string_literal: true

module Exceptions
  # Exception class for handling invalid JWT tokens.
  # Raised when a JWT token is malformed, expired, or otherwise invalid.
  class InvalidTokenError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INVALID_TOKEN])
      super(ErrorCodes::CODES[:INVALID_TOKEN], message, 401)
    end
  end
end
