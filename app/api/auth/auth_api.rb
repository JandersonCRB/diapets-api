
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
            login_result = Auth::Login.call(params).result
            present login_result, with: Entities::LoginEntitiy
          end
        end
      end
    end
  end
