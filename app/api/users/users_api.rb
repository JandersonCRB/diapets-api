# frozen_string_literal: true

module Users
  # API for user management operations including push token registration
  class UsersAPI < Grape::API
    helpers APIHelpers
    namespace :users do
      desc 'Create push token'
      params do
        requires :token, type: String
      end
      post '/push_token' do
        user_authenticate!
        push_token = Users::CreatePushToken.call(decoded_token, params).result
        present push_token, with: Entities::PushTokenEntity
      end
    end
  end
end
