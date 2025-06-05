# frozen_string_literal: true

require 'English'
module Auth
  # Service class responsible for user authentication and login
  # Validates user credentials and generates JWT tokens for successful logins
  # Returns both the token and user information for authenticated sessions
  class Login
    prepend SimpleCommand
    include Helpers::AuthHelpers

    # Initialize the login service with authentication parameters
    # @param params [Hash] Login parameters containing email and password
    def initialize(params)
      Rails.logger.info "Auth::Login initialized for email: #{params[:email]}"
      @params = params
    end

    # Main execution method that orchestrates the login process
    # Validates credentials and returns authentication token with user data
    # @return [Hash] Hash containing authentication token and user object
    # @raise [Exceptions::NotFoundError] If user is not found
    # @raise [Exceptions::InvalidCredentialsError] If password is incorrect
    def call
      Rails.logger.info "Starting login process for email: #{@params[:email]}"

      user = authenticate_user
      token = generate_authentication_token(user)
      build_login_response(user, token)
    rescue Exceptions::NotFoundError, Exceptions::InvalidCredentialsError
      handle_authentication_error($ERROR_INFO)
    rescue StandardError => e
      handle_unexpected_error(e)
    end

    private

    # Authenticate user by finding them and validating their password
    # Combines user lookup and password validation into a single operation
    # @return [User] The authenticated user record
    # @raise [Exceptions::NotFoundError] If user is not found
    # @raise [Exceptions::InvalidCredentialsError] If password is incorrect
    def authenticate_user
      user = find_user
      Rails.logger.info "User found for login: #{user.email} (ID: #{user.id})"

      validate_password(user)
      Rails.logger.info "Password validation successful for user: #{user.email}"

      user
    end

    # Generate authentication token for the authenticated user
    # Creates a JWT token for the user session
    # @param user [User] The authenticated user record
    # @return [String] The generated JWT token
    def generate_authentication_token(user)
      token = generate_token(user)
      Rails.logger.info "Authentication token generated for user: #{user.email}"
      token
    end

    # Build the successful login response
    # Creates the response hash containing token and user data
    # @param user [User] The authenticated user record
    # @param token [String] The generated JWT token
    # @return [Hash] Hash containing authentication token and user object
    def build_login_response(user, token)
      login_response = {
        token: token,
        user: user
      }

      Rails.logger.info "Login successful for user: #{user.email}"
      login_response
    end

    # Find user by email address
    # Searches for a user record with the provided email
    # @return [User] The found user record
    # @raise [Exceptions::NotFoundError] If no user exists with the given email
    def find_user
      Rails.logger.debug "Searching for user with email: #{@params[:email]}"

      # Look up user by email address
      user = User.find_by(email: @params[:email])

      # Validate that user exists
      if user.nil?
        Rails.logger.debug "No user found with email: #{@params[:email]}"
        raise Exceptions::NotFoundError
      end

      Rails.logger.debug "User found: #{user.first_name} #{user.last_name} (ID: #{user.id})"
      user
    end

    # Validate the provided password against the user's stored password
    # Uses Rails' built-in authenticate method for secure password verification
    # @param user [User] The user record to validate password against
    # @raise [Exceptions::InvalidCredentialsError] If password verification fails
    def validate_password(user)
      Rails.logger.debug "Validating password for user: #{user.email}"

      # Authenticate the password using Rails' secure comparison
      authentication_result = user.authenticate(@params[:password])

      # Check if authentication failed
      if authentication_result == false
        Rails.logger.debug "Password validation failed for user: #{user.email}"
        raise Exceptions::InvalidCredentialsError
      end

      Rails.logger.debug "Password validation successful for user: #{user.email}"
    end

    # Handle authentication-related errors (not found, invalid credentials)
    # @param error [Exception] The authentication error that occurred
    # @raise [Exception] Re-raises the original error after logging
    def handle_authentication_error(error)
      case error
      when Exceptions::NotFoundError
        Rails.logger.warn "Login failed: User not found for email #{@params[:email]}"
      when Exceptions::InvalidCredentialsError
        Rails.logger.warn "Login failed: Invalid credentials for email #{@params[:email]}"
      end
      raise error
    end

    # Handle unexpected errors during login process
    # @param error [StandardError] The unexpected error that occurred
    # @raise [StandardError] Re-raises the original error after logging
    def handle_unexpected_error(error)
      Rails.logger.error "Unexpected error during login for #{@params[:email]}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise error
    end
  end
end
