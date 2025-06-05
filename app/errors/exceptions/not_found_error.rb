# frozen_string_literal: true

module Exceptions
  # Exception class for handling 404 Not Found errors.
  # Raised when a requested resource cannot be found on the server.
  class NotFoundError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:NOT_FOUND])
      super(ErrorCodes::CODES[:NOT_FOUND], message, 404)
    end
  end
end
