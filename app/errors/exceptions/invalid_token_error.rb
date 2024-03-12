module Exceptions
  class InvalidTokenError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INVALID_TOKEN])
      super(ErrorCodes::CODES[:INVALID_TOKEN], message, 401)
    end
  end
end