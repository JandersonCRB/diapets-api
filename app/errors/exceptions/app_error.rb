# base interface for errors

module Exceptions
  class AppError < StandardError
    attr_reader :status, :message, :code, :detailed_code

    def initialize(code, message, status = 500, detailed_code: nil)
      @code = code
      @message = message
      @status = status
      @detailed_code = detailed_code
    end
  end
end