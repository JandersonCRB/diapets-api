module Auth
  # Service class for retrieving the current authenticated user
  # Takes a decoded JWT token and returns the corresponding user record
  # Validates that the user still exists in the database
  class CurrentUser
    prepend SimpleCommand
    include Helpers::EnvHelpers

    # Initialize the current user service with decoded token and parameters
    # @param decoded_token [Hash] The decoded JWT token containing user_id
    # @param params [Hash] Request parameters (currently unused but kept for consistency)
    def initialize(decoded_token, params)
      Rails.logger.info "Auth::CurrentUser initialized for user_id: #{decoded_token[:user_id]}"
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method that retrieves the current user
    # Finds the user by ID from the decoded token and validates existence
    # @return [User] The current authenticated user record
    # @raise [Exceptions::NotFoundError] If user is not found in the database
    def call
      Rails.logger.info "Retrieving current user from decoded token"
      
      # Extract user ID from the decoded JWT token
      user_id = @decoded_token[:user_id]
      Rails.logger.debug "Looking up user with ID: #{user_id}"
      
      # Find the user by ID
      user = User.find_by(id: user_id)
      
      # Validate that the user exists
      if user.nil?
        Rails.logger.warn "User not found for ID: #{user_id}"
        raise Exceptions::NotFoundError.new, 'User not found'
      end
      
      Rails.logger.info "Successfully retrieved current user: #{user.email} (ID: #{user.id})"
      Rails.logger.debug "User details: #{user.first_name} #{user.last_name}"
      
      user
    rescue Exceptions::NotFoundError => e
      Rails.logger.error "Current user lookup failed: #{e.message}"
      raise
    rescue => e
      Rails.logger.error "Unexpected error during current user lookup: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end
end