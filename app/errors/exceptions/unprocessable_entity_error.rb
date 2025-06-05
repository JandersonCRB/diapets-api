# frozen_string_literal: true

module Exceptions
  class UnprocessableEntityError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:UNPROCESSABLE_ENTITY], detailed_code: nil)
      super(ErrorCodes::CODES[:UNPROCESSABLE_ENTITY], message, 422, detailed_code: detailed_code)
    end
  end
end
