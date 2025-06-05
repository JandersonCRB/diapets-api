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
      Rails.logger.info "InsulinApplications::Delete initialized for user_id: #{token[:user_id]}, insulin_application_id: #{params[:insulin_application_id]}"
      @token = token
      @params = params
    end

    # Main execution method that orchestrates the deletion process
    # Validates authorization and performs the deletion
    # @return [Boolean] True if deletion was successful
    def call
      Rails.logger.info "Starting insulin application deletion process"
      
      # Find the insulin application record
      insulin_application = find_insulin_application
      Rails.logger.info "Found insulin application with ID: #{insulin_application.id} for pet ID: #{insulin_application.pet_id}"

      # Verify user has permission to delete this insulin application
      validate_pet_permission(user_id, insulin_application.pet_id)
      Rails.logger.info "Authorization validated for user #{user_id} to delete insulin application #{insulin_application.id}"

      # Perform the deletion
      result = insulin_application.destroy
      Rails.logger.info "Successfully deleted insulin application with ID: #{insulin_application.id}"
      
      result
    rescue => e
      Rails.logger.error "Failed to delete insulin application: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
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
      raise Exceptions::NotFoundError.new('Insulin application not found')
    end

  end
end