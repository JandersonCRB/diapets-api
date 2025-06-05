# frozen_string_literal: true

module Entities
  class UserEntity < Grape::Entity
    expose :id
    expose :email
    expose :first_name
    expose :last_name
  end
end
