# frozen_string_literal: true

module InsulinApplications
  # Service class responsible for updating insulin application records
  # Validates authorization and updates the record with new data
  class Update
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the update service with authentication token and parameters
    # @param decoded_token [Hash] Decoded JWT token containing user information
    # @param params [Hash] Request parameters containing insulin_application_id and update data
    def initialize(decoded_token, params)
      user_id = decoded_token[:user_id]
      app_id = params[:insulin_application_id]
      Rails.logger.info "InsulinApplications::Update initialized for user_id: #{user_id}, " \
                        "insulin_application_id: #{app_id}"
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method that orchestrates the update process
    # Validates authorization and performs the update operation
    # @return [InsulinApplication] The updated insulin application record
    def call
      Rails.logger.info 'Starting insulin application update process'

      insulin_application = find_insulin_application
      log_found_application(insulin_application)
      validate_and_authorize(insulin_application)
      execute_update(insulin_application)
    rescue StandardError => e
      handle_update_error(e)
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

    # Update the insulin application with new data
    # @param insulin_application [InsulinApplication] The record to update
    # @return [InsulinApplication] The updated record
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    def update_insulin_application(insulin_application)
      Rails.logger.debug { "Updating insulin application #{insulin_application.id} with new data" }

      # Log original values for audit trail
      log_original_values(insulin_application)

      # Perform the update operation and handle results
      perform_update_operation(insulin_application)
    end

    # Log the original values of the insulin application before update
    # @param insulin_application [InsulinApplication] The record to log
    def log_original_values(insulin_application)
      original_values = {
        application_time: insulin_application.application_time,
        insulin_units: insulin_application.insulin_units,
        glucose_level: insulin_application.glucose_level,
        user_id: insulin_application.user_id,
        observations: insulin_application.observations
      }

      Rails.logger.debug { "Original values: #{original_values}" }
    end

    # Perform the update operation and handle the results
    # @param insulin_application [InsulinApplication] The record to update
    # @return [InsulinApplication] The updated record
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    def perform_update_operation(insulin_application)
      # Perform the update
      insulin_application.update!(update_params)

      Rails.logger.debug { "Updated values: #{update_params}" }
      Rails.logger.info "Insulin application #{insulin_application.id} updated successfully"

      insulin_application
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Validation failed during insulin application update: #{e.message}"
      raise
    end

    # Extract insulin application ID from request parameters
    # @return [String, Integer] The insulin application ID
    def insulin_application_id
      @params[:insulin_application_id]
    end

    # Build hash of parameters for updating the insulin application
    # Maps request parameters to model attributes
    # @return [Hash] Parameters for the update operation
    def update_params
      {
        application_time: @params[:application_time],
        insulin_units: @params[:insulin_units],
        glucose_level: @params[:glucose_level],
        user_id: @params[:responsible_id], # NOTE: maps responsible_id to user_id field
        observations: @params[:observations]
      }
    end

    # Extract user ID from decoded token
    # @return [String, Integer] The authenticated user's ID
    def user_id
      @decoded_token[:user_id]
    end

    # Validate authorization and permissions for the insulin application update
    # @param insulin_application [InsulinApplication] The insulin application to validate
    def validate_and_authorize(insulin_application)
      # Validate that the associated pet exists
      validate_pet_existence(insulin_application.pet_id)
      Rails.logger.debug { "Validated pet existence for pet ID: #{insulin_application.pet_id}" }

      # Verify user has permission to update this insulin application
      validate_pet_permission(user_id, insulin_application.pet_id)
      Rails.logger.info "Authorization validated for user #{user_id} to update " \
                        "insulin application #{insulin_application.id}"
    end

    # Execute the update operation with logging
    # @param insulin_application [InsulinApplication] The insulin application to update
    # @return [InsulinApplication] The updated insulin application record
    def execute_update(insulin_application)
      # Log the update parameters for audit trail
      Rails.logger.debug { "Update parameters: #{update_params}" }

      # Perform the update operation
      updated_application = update_insulin_application(insulin_application)
      Rails.logger.info "Successfully updated insulin application with ID: #{insulin_application.id}"

      updated_application
    end

    # Log information about the found insulin application
    # @param insulin_application [InsulinApplication] The found application
    def log_found_application(insulin_application)
      app_id = insulin_application.id
      pet_id = insulin_application.pet_id
      Rails.logger.info "Found insulin application with ID: #{app_id} for pet ID: #{pet_id}"
    end

    # Handle update errors
    # @param error [StandardError] The error that occurred
    def handle_update_error(error)
      Rails.logger.error "Failed to update insulin application: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise
    end
  end
end
