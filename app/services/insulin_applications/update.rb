module InsulinApplications
  class Update
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      insulin_application = find_insulin_application
      validate_pet_existence(insulin_application.pet_id)
      validate_pet_permission(user_id, insulin_application.pet_id)

      update_insulin_application(insulin_application)
    end

    private

    def find_insulin_application
      InsulinApplication.find_by!(id: insulin_application_id)
    rescue ActiveRecord::RecordNotFound
      raise Exceptions::NotFoundError.new('Insulin application not found')
    end

    def update_insulin_application(insulin_application)
      insulin_application.update!(update_params)
      insulin_application
    end

    def insulin_application_id
      @params[:insulin_application_id]
    end

    def update_params
      {
        application_time: @params[:application_time],
        insulin_units: @params[:insulin_units],
        glucose_level: @params[:glucose_level],
        user_id: @params[:responsible_id],
        observations: @params[:observations]
      }
    end

    def user_id
      @decoded_token[:user_id]
    end
  end
end