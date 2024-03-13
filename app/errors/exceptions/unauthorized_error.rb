module Exceptions
  class UnauthorizedError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:UNAUTHORIZED])
      super(ErrorCodes::CODES[:UNAUTHORIZED], message, 401)
    end
  end
end