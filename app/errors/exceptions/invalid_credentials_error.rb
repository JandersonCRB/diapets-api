# frozen_string_literal: true

module Exceptions
  class InvalidCredentialsError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INVALID_CREDENTIALS])
      super(ErrorCodes::CODES[:INVALID_CREDENTIALS], message, 401)
    end
  end
end
