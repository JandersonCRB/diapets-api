module Pets
  class Create
    prepend SimpleCommand
    include Helpers::DateHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_params
      pet = create_pet
      create_pet_owner(pet)

      pet
    end

    private

    def validate_params
      raise Exceptions::BadRequestError.new('Name is required', detailed_code: 'NAME_REQUIRED') if @params[:name].nil?
      raise Exceptions::BadRequestError.new('Name is too short', detailed_code: 'SHORT_NAME') if @params[:name].length < 2
      raise Exceptions::BadRequestError.new('Name is too big', detailed_code: 'BIG_NAME') if @params[:name].length > 50
      raise Exceptions::BadRequestError.new('Species is required', detailed_code: 'SPECIES_REQUIRED') if @params[:species].nil?
      raise Exceptions::BadRequestError.new('Species is invalid', detailed_code: 'INVALID_SPECIES') unless %w[DOG CAT].include?(@params[:species])
      raise Exceptions::BadRequestError.new('Birthdate is required', detailed_code: 'BIRTHDATE_REQUIRED') if @params[:birthdate].nil?
      raise Exceptions::BadRequestError.new('Birthdate is invalid', detailed_code: 'INVALID_BIRTHDATE') unless date_valid?(@params[:birthdate])
      raise Exceptions::BadRequestError.new('Birthdate is in the future', detailed_code: 'FUTURE_BIRTHDATE') if date_in_future?(@params[:birthdate])
      raise Exceptions::BadRequestError.new('Insulin frequency is required', detailed_code: 'INSULIN_FREQUENCY_REQUIRED') if @params[:insulin_frequency].nil?
      raise Exceptions::BadRequestError.new('Insulin frequency is invalid', detailed_code: 'INVALID_INSULIN_FREQUENCY') unless @params[:insulin_frequency].is_a?(Integer)
      raise Exceptions::BadRequestError.new('Insulin frequency can not be negative', detailed_code: 'NEGATIVE_INSULIN_FREQUENCY') if @params[:insulin_frequency] < 0
      raise Exceptions::BadRequestError.new('Insulin frequency can not be zero', detailed_code: 'ZERO_INSULIN_FREQUENCY') if @params[:insulin_frequency] == 0
      raise Exceptions::BadRequestError.new('Insulin frequency is too big', detailed_code: 'BIG_INSULIN_FREQUENCY') if @params[:insulin_frequency] > 24
    end

    def create_pet
      pet = Pet.new(
        name: @params[:name],
        species: @params[:species],
        birthdate: @params[:birthdate],
        insulin_frequency: @params[:insulin_frequency],
      )
      pet.save!
      pet
    end

    def create_pet_owner(pet)
      pet_owner = PetOwner.new(
        owner_id: @decoded_token[:user_id],
        pet_id: pet.id,
        ownership_level: "OWNER",
      )
      pet_owner.save!
    end
  end
end