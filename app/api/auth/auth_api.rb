
  module Auth
    class AuthAPI < Grape::API
      helpers APIHelpers

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
        namespace :user do
          desc 'Get current user'
          get do
            user_authenticate!
            current_user = Auth::CurrentUser.call(decoded_token, params).result

            status :ok
            present current_user, with: Entities::UserEntity
          end
        end
      end
    end
  end
