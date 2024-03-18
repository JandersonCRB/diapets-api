module Entities
  class PushTokenEntity < Grape::Entity
    expose :id
    expose :token
  end
end