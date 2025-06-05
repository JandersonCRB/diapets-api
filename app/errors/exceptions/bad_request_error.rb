# frozen_string_literal: true

module Exceptions
  # Exception class for handling 400 Bad Request errors.
  # Raised when the client sends a malformed or invalid request.
  class BadRequestError < AppError
    def initialize(message = 'Bad Request', detailed_code: nil)
      super(ErrorCodes::CODES[:BAD_REQUEST], message, 400, detailed_code: detailed_code)
    end
  end
end
