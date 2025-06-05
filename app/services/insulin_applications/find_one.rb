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
      user_id = decoded_token[:user_id]
      app_id = params[:insulin_application_id]
      Rails.logger.info "InsulinApplications::FindOne initialized for user_id: #{user_id}, " \
                        "insulin_application_id: #{app_id}"
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method that retrieves and validates access to insulin application
    # Performs authorization checks before returning the record
    # @return [InsulinApplication] The requested insulin application record
    def call
      Rails.logger.info 'Starting insulin application retrieval process'

      insulin_application = find_insulin_application
      log_found_application(insulin_application)
      authorize_access(insulin_application)
      log_retrieval_success(insulin_application)

      insulin_application
    rescue StandardError => e
      handle_retrieval_error(e)
    end

    private

    # Find insulin application by ID with error handling
    # @return [InsulinApplication] The found insulin application record
    # @raise [Exceptions::NotFoundError] If insulin application is not found
    def find_insulin_application
      Rails.logger.debug { "Searching for insulin application with ID: #{insulin_application_id}" }

      InsulinApplication.find(insulin_application_id)
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

    # Log information about the found insulin application
    # @param insulin_application [InsulinApplication] The found application
    def log_found_application(insulin_application)
      app_id = insulin_application.id
      pet_id = insulin_application.pet_id
      Rails.logger.info "Found insulin application with ID: #{app_id} for pet ID: #{pet_id}"
    end

    # Authorize access to the insulin application
    # @param insulin_application [InsulinApplication] The application to authorize
    def authorize_access(insulin_application)
      pet_id = insulin_application.pet_id
      validate_pet_existence(pet_id)
      Rails.logger.debug { "Validated pet existence for pet ID: #{pet_id}" }

      validate_pet_permission(user_id, pet_id)
      Rails.logger.info "Authorization validated for user #{user_id} to access " \
                        "insulin application #{insulin_application.id}"
    end

    # Log successful retrieval
    # @param insulin_application [InsulinApplication] The retrieved application
    def log_retrieval_success(insulin_application)
      Rails.logger.info "Successfully retrieved insulin application with ID: #{insulin_application.id}"
    end

    # Handle retrieval errors
    # @param error [StandardError] The error that occurred
    def handle_retrieval_error(error)
      Rails.logger.error "Failed to retrieve insulin application: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise
    end
  end
end
