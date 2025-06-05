# frozen_string_literal: true

module Exceptions
  # Exception class for handling 422 Unprocessable Entity errors.
  # Raised when the request is well-formed but contains validation errors or semantic issues.
  class UnprocessableEntityError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:UNPROCESSABLE_ENTITY], detailed_code: nil)
      super(ErrorCodes::CODES[:UNPROCESSABLE_ENTITY], message, 422, detailed_code: detailed_code)
    end
  end
end
