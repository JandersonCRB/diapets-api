# frozen_string_literal: true

module Entities
  # Entity representing user account information
  class UserEntity < Grape::Entity
    expose :id
    expose :email
    expose :first_name
    expose :last_name
  end
end
