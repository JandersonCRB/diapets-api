module InsulinApplications
  class FindOne
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

      insulin_application
    end

    private

    def find_insulin_application
      InsulinApplication.find_by!(id: insulin_application_id)
    rescue ActiveRecord::RecordNotFound
      raise Exceptions::NotFoundError.new('Insulin application not found')
    end

    def insulin_application_id
      @params[:insulin_application_id]
    end

    def user_id
      @decoded_token[:user_id]
    end
  end
end