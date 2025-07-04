# frozen_string_literal: true

# base interface for errors

module Exceptions
  # Base application error class for custom exception handling
  class AppError < StandardError
    attr_reader :status, :message, :code, :detailed_code

    def initialize(code, message, status = 500, detailed_code: nil)
      super(message)
      @code = code
      @message = message
      @status = status
      @detailed_code = detailed_code
    end
  end
end
