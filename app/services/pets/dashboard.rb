module Pets
  class Dashboard
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)
      {
        last_insulin_application: last_insulin_application,
        next_insulin_application: next_insulin_application
      }
    end

    private

    def last_insulin_application
      @last_insulin_application ||= InsulinApplication.where(pet_id: pet_id).order(application_time: :desc).first
    end

    def next_insulin_application
      pet_insulin_frequency = Pet.select(:insulin_frequency).find(pet_id).insulin_frequency
      last_insulin_application&.application_time&.advance(hours: pet_insulin_frequency)
    end

    def pet_id
      @params[:pet_id]
    end

    def user_id
      @decoded_token[:user_id]
    end
  end
end