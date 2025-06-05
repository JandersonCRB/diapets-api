# frozen_string_literal: true

module Exceptions
  # Exception class for handling 401 Unauthorized errors.
  # Raised when a user lacks proper authentication or authorization to access a resource.
  class UnauthorizedError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:UNAUTHORIZED])
      super(ErrorCodes::CODES[:UNAUTHORIZED], message, 401)
    end
  end
end
