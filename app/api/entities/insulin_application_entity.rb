# frozen_string_literal: true

module Entities
  class InsulinApplicationEntity < Grape::Entity
    expose :id
    expose :glucose_level
    expose :insulin_units
    expose :application_time
    expose :observations
    expose :user, using: Entities::UserEntity
  end
end
