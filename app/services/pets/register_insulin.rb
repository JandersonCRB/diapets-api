module Pets
  class RegisterInsulin
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_user_existence(@params[:responsible_id])
      validate_pet_existence(pet_id)
      validate_pet_permission(@decoded_token[:user_id], pet_id)
      validate_pet_permission(@params[:responsible_id], pet_id)
      insulin_application = register_insulin
      notify_pet_owners(pet_id, insulin_application)
      insulin_application
    end

    private

    def notify_pet_owners(pet_id, insulin_application)
      pets = Pet.select(:id, :name)
               .includes(owners: :push_tokens)
               .where(id: pet_id)

      if pets.empty?
        Rails.logger.info("No pets found while notifying pet owners of insulin registration")
        return
      end
      pets.each do |pet|
        push_tokens = []
        pet.owners.each do |owner|
          owner.push_tokens.each do |push_token|
            push_tokens << push_token.token
          end
        end

        PushNotifications::NotifyUsers.call(
          push_tokens,
          "#{pet.name}: Insulina registrada!",
          "#{responsible.first_name} acabou de registrar uma aplicação de insulina"
        )
      end
    end

    def register_insulin
      InsulinApplication.create!(
        pet_id: pet_id,
        user_id: @params[:responsible_id],
        glucose_level: @params[:glucose_level],
        insulin_units: @params[:insulin_units],
        application_time: @params[:application_time],
        observations: @params[:observations]
      )
    end

    def validate_user_existence(user_id)
      return if User.exists?(user_id)

      raise Exceptions::NotFoundError, 'User not found'
    end

    def validate_pet_existence(pet_id)
      return if Pet.exists?(id: pet_id)

      raise Exceptions::NotFoundError.new
    end

    def pet_id
      @params[:pet_id]
    end

    def responsible
      @responsible ||= User.find(@params[:responsible_id])
    end
  end
end