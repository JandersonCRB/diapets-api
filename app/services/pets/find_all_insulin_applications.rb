module Pets
  class FindAllInsulinApplications
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)

      insulin_applications
    end

    private

    def insulin_applications
      InsulinApplication.where(filters).order(application_time: :desc)
    end

    def filters
      { pet_id: pet_id }
    end

    def pet_id
      @params[:pet_id]
    end

    def user_id
      @decoded_token[:user_id]
    end
  end
end