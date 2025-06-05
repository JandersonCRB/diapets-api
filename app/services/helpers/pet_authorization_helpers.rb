# frozen_string_literal: true

module Helpers
  # Helper module for pet-related authorization and validation operations
  # Provides methods to verify user permissions and pet existence
  # Used across services to ensure proper access control for pet data
  module PetAuthorizationHelpers
    # Validate that a user has permission to access a specific pet
    # Checks the PetOwner relationship to ensure proper authorization
    # @param user_id [String, Integer] The ID of the user requesting access
    # @param pet_id [String, Integer] The ID of the pet being accessed
    # @param owner_permission [Boolean] If true, requires OWNER level permission (default: false)
    # @raise [Exceptions::UnauthorizedError] If user lacks permission to access the pet
    def validate_pet_permission(user_id, pet_id, owner_permission: false)
      Rails.logger.info "Validating pet permission for user #{user_id} on pet #{pet_id}"
      Rails.logger.debug "Owner permission required: #{owner_permission}"

      # Build query parameters for permission check
      query_params = {
        owner_id: user_id,
        pet_id: pet_id
      }

      # Add ownership level requirement if specified
      if owner_permission
        query_params[:ownership_level] = 'OWNER'
        Rails.logger.debug 'Checking for OWNER level permission'
      end

      Rails.logger.debug "Query parameters for permission check: #{query_params}"

      # Check if the pet ownership relationship exists
      if PetOwner.exists?(query_params)
        Rails.logger.info "Permission validated: User #{user_id} has access to pet #{pet_id}"
        return
      end

      # Log authorization failure
      Rails.logger.warn "Authorization failed: User #{user_id} lacks permission for pet #{pet_id}"
      Rails.logger.warn "Required ownership level: #{owner_permission ? 'OWNER' : 'any'}"

      raise Exceptions::UnauthorizedError
    end

    # Validate that a pet exists in the database
    # Ensures the pet ID refers to a valid, existing pet record
    # @param pet_id [String, Integer] The ID of the pet to validate
    # @raise [Exceptions::NotFoundError] If the pet does not exist
    def validate_pet_existence(pet_id)
      Rails.logger.debug "Validating existence of pet with ID: #{pet_id}"

      # Check if the pet exists in the database
      if Pet.exists?(id: pet_id)
        Rails.logger.debug "Pet existence validated: Pet #{pet_id} exists"
        return
      end

      # Log pet not found
      Rails.logger.warn "Pet not found: Pet with ID #{pet_id} does not exist"

      raise Exceptions::NotFoundError
    end
  end
end
