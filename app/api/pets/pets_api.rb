module Pets
  class PetsAPI < Grape::API
    helpers APIHelpers
    namespace :pets do
      desc 'Get pet list'
      get '' do
        user_authenticate!
        pets = Pets::FindAllByUser.call(decoded_token, params).result

        present pets, with: Entities::PetEntity
      end

      route_param :pet_id do
        desc 'Get pet dashboard'
        get '/dashboard' do
          user_authenticate!
          dashboard = Pets::Dashboard.call(decoded_token, params).result

          present dashboard, with: Entities::PetDashboardEntity
        end
        
        namespace :insulin_applications do
          desc 'Register insulin application'
          params do
            requires :glucose_level, type: Integer
            requires :insulin_units, type: Integer
            requires :application_time, type: DateTime
            requires :responsible_id, type: Integer
            optional :observations, type: String
          end
          post '' do
            user_authenticate!
            insulin_application = Pets::RegisterInsulin.call(decoded_token, params)
            present insulin_application.result, with: Entities::InsulinApplicationEntity
          end
        end
      end
    end
  end
end