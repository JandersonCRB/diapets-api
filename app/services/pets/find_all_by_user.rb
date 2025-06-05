module Pets
  # Service class for finding all pets owned by a specific user
  # Retrieves pets associated with the authenticated user through ownership relationships
  class FindAllByUser
    prepend SimpleCommand

    # Initialize the service with user authentication token
    # @param decoded_token [Hash] JWT token containing user authentication data
    # @param params [Hash] Additional parameters (currently unused)
    def initialize(decoded_token, params)
      Rails.logger.info("Pets::FindAllByUser initialized for user_id: #{decoded_token[:user_id]}")
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method for retrieving user's pets
    # Validates user existence and returns all owned pets with associations
    # @return [ActiveRecord::Relation] Collection of pets owned by the user
    def call
      Rails.logger.info("Finding all pets for user_id: #{user_id}")
      
      validate_user_existence
      
      pets = Pet.includes(:owners).where(pet_owners: { pet_id: pet_ids })
      
      Rails.logger.info("Found #{pets.count} pets for user_id: #{user_id}")
      pets
    end

    private

    # Retrieves all pet IDs owned by the current user
    # Uses memoization to prevent multiple database queries
    # @return [Array<Integer>] Array of pet IDs owned by the user
    def pet_ids
      Rails.logger.debug("Fetching pet IDs for user_id: #{user_id}")
      @pet_ids ||= PetOwner.where(owner_id: user_id).pluck(:pet_id)
    end

    # Extracts user_id from decoded JWT token with memoization
    # @return [Integer] The user ID from authentication token
    def user_id
      @user_id ||= @decoded_token[:user_id]
    end

    # Validates that the authenticated user exists in the database
    # Raises internal server error if user is not found
    # @raise [Exceptions::InternalServerError] When user doesn't exist
    def validate_user_existence
      Rails.logger.debug("Validating existence of user_id: #{user_id}")
      
      return if User.exists?(user_id)

      Rails.logger.error("User not found: #{user_id}")
      raise Exceptions::InternalServerError, 'User not found'
    end
  end
end