module Pets
  class InsulinApplicationAPI < Grape::API
    helpers APIHelpers

    namespace :pets do
      route_param :pet_id do
        namespace :insulin_applications do
          desc 'List all the pet insulin applications'
          params do
            optional :min_date, type: DateTime, desc: 'The minimum date of the insulin applications'
            optional :max_date, type: DateTime, desc: 'The maximum date of the insulin applications'
            optional :min_units, type: Integer, desc: 'The minimum insulin units of the insulin applications'
            optional :max_units, type: Integer, desc: 'The maximum insulin units of the insulin applications'
            optional :min_glucose, type: Integer, desc: 'The minimum glucose level of the insulin applications'
            optional :max_glucose, type: Integer, desc: 'The maximum glucose level of the insulin applications'
          end
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

    namespace :insulin_applications do
      route_param :insulin_application_id do
        desc 'Get the pet insulin application'
        get '' do
          user_authenticate!
          insulin_application = InsulinApplications::FindOne.call(decoded_token, params).result

          present insulin_application, with: Entities::InsulinApplicationEntity
        end

        desc 'Update the pet insulin application'
        params do
          requires :application_time, type: DateTime, desc: 'The time of the insulin application'
          requires :insulin_units, type: Integer, desc: 'The insulin units of the insulin application'
          requires :glucose_level, type: Integer, desc: 'The glucose level of the insulin application'
          requires :user_id, type: Integer, desc: 'The user id of the insulin application'
        end
        put '' do
          user_authenticate!
          insulin_application = InsulinApplications::Update.call(decoded_token, params).result

          present insulin_application, with: Entities::InsulinApplicationEntity
        end
      end
    end
  end
end