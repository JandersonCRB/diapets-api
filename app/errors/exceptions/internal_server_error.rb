# frozen_string_literal: true

module Exceptions
  # Exception class for handling 500 Internal Server errors.
  # Raised when an unexpected error occurs on the server side.
  class InternalServerError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INTERNAL_SERVER_ERROR])
      super(ErrorCodes::CODES[:INTERNAL_SERVER_ERROR], message, 500)
    end
  end
end
