# frozen_string_literal: true

module Entities
  # Entity representing user login response with authentication token
  class LoginEntity < Grape::Entity
    expose :token
    expose :user, using: Entities::UserEntity
  end
end
