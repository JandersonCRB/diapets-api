# frozen_string_literal: true

module Pets
  # Service class for registering insulin applications for pets
  # Handles insulin dose recording and notification to pet owners
  class RegisterInsulin
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the insulin registration service
    # @param decoded_token [Hash] JWT token containing requesting user authentication data
    # @param params [Hash] Insulin application parameters including pet_id, responsible_id, etc.
    def initialize(decoded_token, params)
      Rails.logger.info("Pets::RegisterInsulin initialized for user_id: #{decoded_token[:user_id]}, " \
                        "pet_id: #{params[:pet_id]}")
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method for insulin registration
    # Validates permissions, records insulin application, and notifies owners
    # @return [InsulinApplication] The created insulin application record
    def call
      Rails.logger.info("Registering insulin for pet_id: #{pet_id}, responsible_id: #{@params[:responsible_id]}")

      # Validate all required permissions and data
      validate_user_existence(@params[:responsible_id])
      validate_pet_existence(pet_id)
      validate_pet_permission(@decoded_token[:user_id], pet_id)
      validate_pet_permission(@params[:responsible_id], pet_id)

      # Create insulin application record
      insulin_application = register_insulin

      # Notify all pet owners about the insulin application
      notify_pet_owners(pet_id, insulin_application)

      Rails.logger.info("Successfully registered insulin application with ID: #{insulin_application.id}")
      insulin_application
    end

    private

    # Sends push notifications to all owners of the pet about the insulin registration
    # Collects push tokens from all owners and sends notification about the application
    # @param pet_id [Integer] ID of the pet that received insulin
    # @param insulin_application [InsulinApplication] The created insulin application record
    def notify_pet_owners(pet_id, _insulin_application)
      Rails.logger.info("Sending insulin registration notifications for pet_id: #{pet_id}")

      pets = retrieve_pets_with_owners(pet_id)

      pets.each do |pet|
        Rails.logger.debug("Processing notifications for pet: #{pet.name}")

        push_tokens = collect_push_tokens_for_pet(pet)
        send_notification_to_pet_owners(pet, push_tokens) if push_tokens.any?
      end
    end

    # Creates a new insulin application record in the database
    # Records all insulin application details including glucose level and dosage
    # @return [InsulinApplication] The created insulin application record
    def register_insulin
      Rails.logger.info("Creating insulin application record with params: #{insulin_params.inspect}")

      insulin_application = create_insulin_application(build_insulin_parameters)

      Rails.logger.info("Insulin application created successfully with ID: #{insulin_application.id}")
      insulin_application
    end

    # Helper method to return insulin parameters for logging
    # @return [Hash] Sanitized insulin parameters for logging
    def insulin_params
      {
        pet_id: pet_id,
        responsible_id: @params[:responsible_id],
        glucose_level: @params[:glucose_level],
        insulin_units: @params[:insulin_units],
        application_time: @params[:application_time],
        observations: @params[:observations]&.truncate(50) # Truncate observations for logging
      }
    end

    # Validates that a user exists in the database
    # @param user_id [Integer] The user ID to validate
    # @raise [Exceptions::NotFoundError] When user doesn't exist
    def validate_user_existence(user_id)
      Rails.logger.debug("Validating existence of user_id: #{user_id}")

      return if User.exists?(user_id)

      Rails.logger.error("User not found: #{user_id}")
      raise Exceptions::NotFoundError, 'User not found'
    end

    # Validates that a pet exists in the database
    # @param pet_id [Integer] The pet ID to validate
    # @raise [Exceptions::NotFoundError] When pet doesn't exist
    def validate_pet_existence(pet_id)
      Rails.logger.debug("Validating existence of pet_id: #{pet_id}")

      return if Pet.exists?(id: pet_id)

      Rails.logger.error("Pet not found: #{pet_id}")
      raise Exceptions::NotFoundError
    end

    # Extracts pet_id from request parameters
    # @return [Integer] The pet ID from parameters
    def pet_id
      @params[:pet_id]
    end

    # Retrieves pets with their owners and push tokens
    # @param pet_id [Integer] ID of the pet
    # @return [ActiveRecord::Relation] Pets with included owners and push tokens
    def retrieve_pets_with_owners(pet_id)
      Pet.select(:id, :name)
         .includes(owners: :push_tokens)
         .where(id: pet_id)
    end

    # Collects all push tokens for a pet's owners
    # @param pet [Pet] The pet object with included owners and push tokens
    # @return [Array<String>] Array of push token strings
    def collect_push_tokens_for_pet(pet)
      push_tokens = []
      pet.owners.each do |owner|
        owner.push_tokens.each do |push_token|
          push_tokens << push_token.token
        end
      end

      Rails.logger.debug("Collected #{push_tokens.size} push tokens for pet #{pet.name}")
      push_tokens
    end

    # Sends notification to all owners of a pet
    # @param pet [Pet] The pet object
    # @param push_tokens [Array<String>] Array of push token strings
    def send_notification_to_pet_owners(pet, push_tokens)
      PushNotifications::NotifyUsers.call(
        push_tokens,
        "#{pet.name}: Insulina registrada!",
        "#{responsible.first_name} acabou de registrar uma aplicação de insulina"
      )

      Rails.logger.info("Insulin registration notifications sent for pet: #{pet.name}")
    end

    # Builds parameters for insulin application creation
    # @return [Hash] Parameters for InsulinApplication.create!
    def build_insulin_parameters
      {
        pet_id: pet_id,
        user_id: @params[:responsible_id],
        glucose_level: @params[:glucose_level],
        insulin_units: @params[:insulin_units],
        application_time: @params[:application_time],
        observations: @params[:observations]
      }
    end

    # Creates the insulin application record
    # @param parameters [Hash] Parameters for creating the insulin application
    # @return [InsulinApplication] The created insulin application record
    def create_insulin_application(parameters)
      InsulinApplication.create!(parameters)
    end

    # Retrieves the responsible user who is applying the insulin
    # Uses memoization to prevent multiple database queries
    # @return [User] The user responsible for the insulin application
    def responsible
      @responsible ||= User.find(@params[:responsible_id])
    end
  end
end
