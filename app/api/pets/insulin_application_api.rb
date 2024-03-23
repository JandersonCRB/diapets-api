module Pets
  class InsulinApplicationAPI < Grape::API
    helpers APIHelpers

    namespace :pets do
      route_param :pet_id do
        namespace :insulin_applications do
          desc 'List all the pet insulin applications'
          get '' do
            user_authenticate!
            insulin_applications = Pets::FindAllInsulinApplications.call(decoded_token, params).result

            present insulin_applications, with: Entities::InsulinApplicationEntity
          end

          desc 'Get the filters option values for the pet insulin applications'
          get 'filters' do
            user_authenticate!
            filters = InsulinApplications::GetFilters.call(decoded_token, params).result

            present filters, with: Entities::InsulinApplicationsFiltersEntity
          end
        end

      end
    end
  end
end