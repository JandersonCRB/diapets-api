# frozen_string_literal: true

module Entities
  # Entity representing push notification token for mobile devices
  class PushTokenEntity < Grape::Entity
    expose :id
    expose :token
  end
end
