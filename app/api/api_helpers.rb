# frozen_string_literal: true

# Helper module providing authentication utilities for API endpoints
module APIHelpers
  module_function

  def decoded_token
    @decoded_token ||= Auth::Authorize.call(headers).result
  end

  def user_authenticate!(token: nil)
    headers['authorization'] = "Bearer #{token}" unless token.nil?

    error!('401 Unauthorized', 401) unless decoded_token
  end
end
