module Exceptions
  class BadRequestError < AppError
    def initialize(message = 'Bad Request', detailed_code: nil)
      super(ErrorCodes::CODES[:BAD_REQUEST], message, 400, detailed_code: detailed_code)
    end
  end
end