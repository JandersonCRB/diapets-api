# frozen_string_literal: true

module Entities
  # Entity representing pet information including basic details and owners
  class PetEntity < Grape::Entity
    expose :id
    expose :name
    expose :species
    expose :birthdate
    expose :owners, using: Entities::UserEntity
  end
end
