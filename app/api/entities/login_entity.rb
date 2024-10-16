module Entities
  class LoginEntity < Grape::Entity
    expose :token
    expose :user, using: Entities::UserEntity
  end
end