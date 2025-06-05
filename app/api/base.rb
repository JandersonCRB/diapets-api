# frozen_string_literal: true

# Base API class that mounts all API modules and handles error responses
class Base < Grape::API
  get do
    { hello: 'world' }
  end

  rescue_from Exceptions::InternalServerError do |e|
    error_details = "Unexpected error:\nType: #{e.class}\nMessage:#{e.message}\n" \
                    "Code: #{e.code}\nStatus:#{e.status}\nBacktrace: #{e.backtrace.join("\n")}"
    Rails.logger.error(error_details)
    error!({ error_code: e.code, error_message: e.message }, e.status)
  end

  rescue_from Exceptions::AppError do |e|
    error_response = { error_code: e.code, error_message: e.message, detailed_code: e.detailed_code }
    error!(error_response, e.status)
  end

  mount Auth::AuthAPI
  mount Pets::PetsAPI
  mount Pets::InsulinApplicationAPI
  mount Users::UsersAPI
end
