# frozen_string_literal: true

# Base API class that mounts all API modules and handles error responses
class Base < Grape::API
  get do
    { hello: 'world' }
  end

  rescue_from Exceptions::InternalServerError do |e|
    Rails.logger.error("Unexpected error:\nType: #{e.class}\nMessage:#{e.message}\nCode: #{e.code}\nStatus:#{e.status}\nBacktrace: #{e.backtrace.join("\n")}")
    error!({ error_code: e.code, error_message: e.message }, e.status)
  end

  rescue_from Exceptions::AppError do |e|
    error!({ error_code: e.code, error_message: e.message, detailed_code: e.detailed_code }, e.status)
  end

  mount Auth::AuthAPI
  mount Pets::PetsAPI
  mount Pets::InsulinApplicationAPI
  mount Users::UsersAPI
end
