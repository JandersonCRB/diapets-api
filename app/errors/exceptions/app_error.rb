# base interface for errors

module Exceptions
  class AppError < StandardError
    attr_reader :status, :message

    def initialize(code, message, status = 500)
      @code = code
      @message = message
      @status = status
    end
  end
end