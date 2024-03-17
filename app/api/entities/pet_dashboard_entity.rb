module Entities
  class PetDashboardEntity < Grape::Entity
    format_with(:default_datetime) do |date_time|
      date_time.strftime('%Y-%m-%dT%H:%M:%S')
    end

    expose :last_insulin_application, using: Entities::InsulinApplicationEntity
    expose :next_insulin_application, format_with: :default_datetime
  end
end