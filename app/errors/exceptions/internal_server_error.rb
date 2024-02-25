module Exceptions
  class InternalServerError < AppError
    def initialize(message = ErrorMessages::MESSAGES[:INTERNAL_SERVER_ERROR])
      super(ErrorCodes::CODES[:INTERNAL_SERVER_ERROR], message, 500)
    end
  end
end