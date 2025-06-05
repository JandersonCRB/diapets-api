# frozen_string_literal: true

module InsulinApplications
  # Service class responsible for deleting insulin application records
  # Ensures proper authorization before allowing deletion operations
  class Delete
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the delete service with authentication token and parameters
    # @param token [Hash] Decoded JWT token containing user information
    # @param params [Hash] Request parameters containing insulin_application_id
    def initialize(token, params)
      user_id = token[:user_id]
      app_id = params[:insulin_application_id]
      Rails.logger.info "InsulinApplications::Delete initialized for user_id: #{user_id}, " \
                        "insulin_application_id: #{app_id}"
      @token = token
      @params = params
    end

    # Main execution method that orchestrates the deletion process
    # Validates authorization and performs the deletion
    # @return [Boolean] True if deletion was successful
    def call
      Rails.logger.info 'Starting insulin application deletion process'

      insulin_application = find_insulin_application
      log_found_application(insulin_application)
      authorize_deletion(insulin_application)
      perform_deletion(insulin_application)
    rescue StandardError => e
      handle_deletion_error(e)
    end

    private

    # Extract insulin application ID from request parameters
    # @return [String, Integer] The insulin application ID
    def insulin_application_id
      @params[:insulin_application_id]
    end

    # Extract user ID from decoded token
    # @return [String, Integer] The authenticated user's ID
    def user_id
      @token[:user_id]
    end

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

    # Log information about the found insulin application
    # @param insulin_application [InsulinApplication] The found application
    def log_found_application(insulin_application)
      app_id = insulin_application.id
      pet_id = insulin_application.pet_id
      Rails.logger.info "Found insulin application with ID: #{app_id} for pet ID: #{pet_id}"
    end

    # Authorize the deletion operation
    # @param insulin_application [InsulinApplication] The application to authorize
    def authorize_deletion(insulin_application)
      pet_id = insulin_application.pet_id
      validate_pet_permission(user_id, pet_id)
      Rails.logger.info "Authorization validated for user #{user_id} to delete " \
                        "insulin application #{insulin_application.id}"
    end

    # Perform the actual deletion
    # @param insulin_application [InsulinApplication] The application to delete
    # @return [Boolean] True if deletion was successful
    def perform_deletion(insulin_application)
      result = insulin_application.destroy
      Rails.logger.info "Successfully deleted insulin application with ID: #{insulin_application.id}"
      result
    end

    # Handle deletion errors
    # @param error [StandardError] The error that occurred
    def handle_deletion_error(error)
      Rails.logger.error "Failed to delete insulin application: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise
    end
  end
end
