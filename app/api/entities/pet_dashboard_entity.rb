# frozen_string_literal: true

module Entities
  class PetDashboardEntity < Grape::Entity
    expose :last_insulin_application, using: Entities::InsulinApplicationEntity
    expose :next_insulin_application
  end
end
