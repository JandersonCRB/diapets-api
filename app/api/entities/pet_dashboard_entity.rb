# frozen_string_literal: true

module Entities
  # Entity representing pet dashboard information with recent and next insulin data
  class PetDashboardEntity < Grape::Entity
    expose :last_insulin_application, using: Entities::InsulinApplicationEntity
    expose :next_insulin_application
  end
end
