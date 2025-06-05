# frozen_string_literal: true

module InsulinApplications
  # Service class for retrieving a single insulin application record
  # Includes authorization checks to ensure user can access the requested data
  class FindOne
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the find service with authentication token and parameters
    # @param decoded_token [Hash] Decoded JWT token containing user information
    # @param params [Hash] Request parameters containing insulin_application_id
    def initialize(decoded_token, params)
      Rails.logger.info "InsulinApplications::FindOne initialized for user_id: #{decoded_token[:user_id]}, insulin_application_id: #{params[:insulin_application_id]}"
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method that retrieves and validates access to insulin application
    # Performs authorization checks before returning the record
    # @return [InsulinApplication] The requested insulin application record
    def call
      Rails.logger.info 'Starting insulin application retrieval process'

      # Find the insulin application record
      insulin_application = find_insulin_application
      Rails.logger.info "Found insulin application with ID: #{insulin_application.id} for pet ID: #{insulin_application.pet_id}"

      # Validate that the associated pet exists
      validate_pet_existence(insulin_application.pet_id)
      Rails.logger.debug "Validated pet existence for pet ID: #{insulin_application.pet_id}"

      # Verify user has permission to access this insulin application
      validate_pet_permission(user_id, insulin_application.pet_id)
      Rails.logger.info "Authorization validated for user #{user_id} to access insulin application #{insulin_application.id}"

      Rails.logger.info "Successfully retrieved insulin application with ID: #{insulin_application.id}"
      insulin_application
    rescue StandardError => e
      Rails.logger.error "Failed to retrieve insulin application: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

    # Find insulin application by ID with error handling
    # @return [InsulinApplication] The found insulin application record
    # @raise [Exceptions::NotFoundError] If insulin application is not found
    def find_insulin_application
      Rails.logger.debug "Searching for insulin application with ID: #{insulin_application_id}"

      InsulinApplication.find_by!(id: insulin_application_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Insulin application not found with ID: #{insulin_application_id}"
      raise Exceptions::NotFoundError, 'Insulin application not found'
    end

    # Extract insulin application ID from request parameters
    # @return [String, Integer] The insulin application ID
    def insulin_application_id
      @params[:insulin_application_id]
    end

    # Extract user ID from decoded token
    # @return [String, Integer] The authenticated user's ID
    def user_id
      @decoded_token[:user_id]
    end
  end
end
