module Entities
  class LoginEntitiy < Grape::Entity
    expose :token
    expose :user, using: Entities::UserEntity
  end
end