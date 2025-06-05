# frozen_string_literal: true

module Entities
  class PushTokenEntity < Grape::Entity
    expose :id
    expose :token
  end
end
