
  class Base < Grape::API
    get do
      { hello: 'world' }
    end

    mount Auth::AuthAPI

    rescue_from Exceptions::AppError do |e|
      error!({ error_code: e.code, error_message: e.message }, e.status)
    end
  end
