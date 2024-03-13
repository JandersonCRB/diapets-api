module Entities
  class InsulinApplicationEntity < Grape::Entity
    expose :id
    expose :glucose_level
    expose :insulin_units
    expose :application_time
    expose :observations
  end
end