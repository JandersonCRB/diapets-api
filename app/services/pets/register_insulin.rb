module Pets
  class RegisterInsulin
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)
      register_insulin
    end

    private

    def register_insulin
      InsulinApplication.create!(
        pet_id: pet_id,
        user_id: user_id,
        glucose_level: @params[:glucose_level],
        insulin_units: @params[:insulin_units],
        application_time: @params[:application_time],
        observations: @params[:observations]
      )
    end

    def validate_pet_existence(pet_id)
      return if Pet.exists?(id: pet_id)

      raise Exceptions::NotFoundError.new
    end

    def pet_id
      @params[:pet_id]
    end

    def user_id
      @decoded_token[:user_id]
    end
  end
end