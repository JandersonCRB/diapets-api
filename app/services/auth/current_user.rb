# frozen_string_literal: true

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
      Rails.logger.info 'Retrieving current user from decoded token'

      user_id = extract_user_id
      user = find_user(user_id)
      validate_user_existence(user, user_id)
      log_user_success(user)

      user
    rescue Exceptions::NotFoundError => e
      handle_not_found_error(e)
    rescue StandardError => e
      handle_unexpected_error(e)
    end

    private

    # Extract user ID from the decoded JWT token
    # @return [String, Integer] The user ID
    def extract_user_id
      user_id = @decoded_token[:user_id]
      Rails.logger.debug { "Looking up user with ID: #{user_id}" }
      user_id
    end

    # Find user by ID
    # @param user_id [String, Integer] The user ID to find
    # @return [User, nil] The found user or nil
    def find_user(user_id)
      User.find_by(id: user_id)
    end

    # Validate that the user exists
    # @param user [User, nil] The found user
    # @param user_id [String, Integer] The user ID for error messages
    # @raise [Exceptions::NotFoundError] If user is nil
    def validate_user_existence(user, user_id)
      return unless user.nil?

      Rails.logger.warn "User not found for ID: #{user_id}"
      raise Exceptions::NotFoundError.new, 'User not found'
    end

    # Log successful user retrieval
    # @param user [User] The retrieved user
    def log_user_success(user)
      Rails.logger.info "Successfully retrieved current user: #{user.email} (ID: #{user.id})"
      Rails.logger.debug { "User details: #{user.first_name} #{user.last_name}" }
    end

    # Handle not found errors
    # @param error [Exceptions::NotFoundError] The not found error
    def handle_not_found_error(error)
      Rails.logger.error "Current user lookup failed: #{error.message}"
      raise
    end

    # Handle unexpected errors during user lookup
    # @param error [StandardError] The unexpected error
    def handle_unexpected_error(error)
      Rails.logger.error "Unexpected error during current user lookup: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise
    end
  end
end
