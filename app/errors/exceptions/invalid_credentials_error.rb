# frozen_string_literal: true

module Exceptions
  # Exception class for handling authentication failures.
  # Raised when user provides incorrect username/password or other invalid credentials.
  class InvalidCredentialsError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INVALID_CREDENTIALS])
      super(ErrorCodes::CODES[:INVALID_CREDENTIALS], message, 401)
    end
  end
end
