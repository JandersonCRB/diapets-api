
  class Base < Grape::API
    get do
      { hello: 'world' }
    end

    rescue_from Exceptions::InternalServerError do |e|
      Rails.logger.error(e)
      error!({ error_code: e.code, error_message: e.message }, e.status)
    end

    rescue_from Exceptions::AppError do |e|
      error!({ error_code: e.code, error_message: e.message }, e.status)
    end

    mount Auth::AuthAPI
    mount Pets::PetsAPI
    mount Pets::InsulinApplicationAPI
  end
