# frozen_string_literal: true

module Pets
  # Service class responsible for creating new pets in the system
  # Handles pet creation, validation, and ownership association
  class Create
    prepend SimpleCommand
    include Helpers::DateHelpers

    # Initialize the service with user authentication token and pet parameters
    # @param decoded_token [Hash] JWT token containing user authentication data
    # @param params [Hash] Pet creation parameters (name, species, birthdate, etc.)
    def initialize(decoded_token, params)
      Rails.logger.info("Pets::Create initialized for user_id: #{decoded_token[:user_id]}")
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method for pet creation
    # Validates input parameters, creates pet record, and establishes ownership
    # @return [Pet] The created pet instance
    def call
      Rails.logger.info("Starting pet creation process with params: #{@params.inspect}")

      validate_params
      pet = create_pet
      create_pet_owner(pet)

      Rails.logger.info("Successfully created pet with ID: #{pet.id}")
      pet
    end

    private

    # Validates all input parameters for pet creation
    # Ensures name, species, birthdate, and insulin frequency meet requirements
    def validate_params
      Rails.logger.info('Validating pet creation parameters')

      validate_name
      validate_species
      validate_birthdate
      validate_insulin_frequency

      Rails.logger.info('Pet parameters validation completed successfully')
    end

    # Validates pet name requirements
    # Name must be present and between 2-50 characters
    def validate_name
      raise Exceptions::BadRequestError.new('Name is required', detailed_code: 'NAME_REQUIRED') if @params[:name].nil?

      if @params[:name].length < 2
        raise Exceptions::BadRequestError.new('Name is too short',
                                              detailed_code: 'SHORT_NAME')
      end
      raise Exceptions::BadRequestError.new('Name is too big', detailed_code: 'BIG_NAME') if @params[:name].length > 50
    end

    # Validates pet species requirements
    # Species must be present and only dogs and cats are supported
    def validate_species
      if @params[:species].nil?
        raise Exceptions::BadRequestError.new('Species is required',
                                              detailed_code: 'SPECIES_REQUIRED')
      end
      return if %w[DOG CAT].include?(@params[:species])

      raise Exceptions::BadRequestError.new('Species is invalid',
                                            detailed_code: 'INVALID_SPECIES')
    end

    # Validates pet birthdate requirements
    # Birthdate must be valid date and not in the future
    def validate_birthdate
      validate_birthdate_presence
      validate_birthdate_format
      validate_birthdate_not_future
    end

    # Validates that birthdate is present
    def validate_birthdate_presence
      return unless @params[:birthdate].nil?

      raise Exceptions::BadRequestError.new('Birthdate is required',
                                            detailed_code: 'BIRTHDATE_REQUIRED')
    end

    # Validates that birthdate has valid format
    def validate_birthdate_format
      return if date_valid?(@params[:birthdate])

      raise Exceptions::BadRequestError.new('Birthdate is invalid',
                                            detailed_code: 'INVALID_BIRTHDATE')
    end

    # Validates that birthdate is not in the future
    def validate_birthdate_not_future
      return unless date_in_future?(@params[:birthdate])

      raise Exceptions::BadRequestError.new('Birthdate is in the future',
                                            detailed_code: 'FUTURE_BIRTHDATE')
    end

    # Validates insulin frequency requirements
    # Frequency must be positive integer between 1-24 hours
    def validate_insulin_frequency
      validate_insulin_frequency_presence
      validate_insulin_frequency_type
      validate_insulin_frequency_range
    end

    # Creates a new pet record in the database
    # @return [Pet] The created pet instance
    def create_pet
      Rails.logger.info("Creating new pet with name: #{@params[:name]}, species: #{@params[:species]}")

      pet = Pet.new(
        name: @params[:name],
        species: @params[:species],
        birthdate: @params[:birthdate],
        insulin_frequency: @params[:insulin_frequency]
      )
      pet.save!

      Rails.logger.info("Pet created successfully with ID: #{pet.id}")
      pet
    end

    # Creates ownership relationship between user and pet
    # Sets the user as the primary owner of the newly created pet
    # @param pet [Pet] The pet instance to create ownership for
    def create_pet_owner(pet)
      Rails.logger.info("Creating pet ownership for user_id: #{@decoded_token[:user_id]}, pet_id: #{pet.id}")

      pet_owner = PetOwner.new(
        owner_id: @decoded_token[:user_id],
        pet_id: pet.id,
        ownership_level: 'OWNER'
      )
      pet_owner.save!

      Rails.logger.info('Pet ownership created successfully')
    end

    # Validates that insulin frequency is present
    # @raise [Exceptions::BadRequestError] If insulin frequency is missing
    def validate_insulin_frequency_presence
      return unless @params[:insulin_frequency].nil?

      raise Exceptions::BadRequestError.new('Insulin frequency is required',
                                            detailed_code: 'INSULIN_FREQUENCY_REQUIRED')
    end

    # Validates that insulin frequency is an integer
    # @raise [Exceptions::BadRequestError] If insulin frequency is not an integer
    def validate_insulin_frequency_type
      return if @params[:insulin_frequency].is_a?(Integer)

      raise Exceptions::BadRequestError.new('Insulin frequency is invalid',
                                            detailed_code: 'INVALID_INSULIN_FREQUENCY')
    end

    # Validates that insulin frequency is within acceptable range (1-24)
    # @raise [Exceptions::BadRequestError] If insulin frequency is out of range
    def validate_insulin_frequency_range
      validate_not_negative
      validate_not_zero
      validate_not_too_big
    end

    # Validates insulin frequency is not negative
    # @raise [Exceptions::BadRequestError] If insulin frequency is negative
    def validate_not_negative
      return unless @params[:insulin_frequency].negative?

      raise Exceptions::BadRequestError.new('Insulin frequency can not be negative',
                                            detailed_code: 'NEGATIVE_INSULIN_FREQUENCY')
    end

    # Validates insulin frequency is not zero
    # @raise [Exceptions::BadRequestError] If insulin frequency is zero
    def validate_not_zero
      return unless @params[:insulin_frequency].zero?

      raise Exceptions::BadRequestError.new('Insulin frequency can not be zero',
                                            detailed_code: 'ZERO_INSULIN_FREQUENCY')
    end

    # Validates insulin frequency is not greater than 24
    # @raise [Exceptions::BadRequestError] If insulin frequency is too big
    def validate_not_too_big
      return unless @params[:insulin_frequency] > 24

      raise Exceptions::BadRequestError.new('Insulin frequency is too big',
                                            detailed_code: 'BIG_INSULIN_FREQUENCY')
    end
  end
end
