# frozen_string_literal: true

module Exceptions
  class NotFoundError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:NOT_FOUND])
      super(ErrorCodes::CODES[:NOT_FOUND], message, 404)
    end
  end
end
