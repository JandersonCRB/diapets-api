
  module Auth
    class AuthAPI < Grape::API
      namespace :auth do
        namespace :login do
          desc 'Authenticate a user'
          params do
            requires :email, type: String, desc: 'Email'
            requires :password, type: String, desc: 'Password'
          end
          post do
            status :ok
            Auth::Login.call(params).result
          end
        end
      end
    end
  end
