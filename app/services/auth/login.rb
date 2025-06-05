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
      
      # Find the user by email
      user = find_user
      Rails.logger.info "User found for login: #{user.email} (ID: #{user.id})"
      
      # Validate the provided password
      validate_password(user)
      Rails.logger.info "Password validation successful for user: #{user.email}"
      
      # Generate authentication token
      token = generate_token(user)
      Rails.logger.info "Authentication token generated for user: #{user.email}"
      
      # Return successful login response
      login_response = {
        token: token,
        user: user
      }
      
      Rails.logger.info "Login successful for user: #{user.email}"
      login_response
    rescue Exceptions::NotFoundError => e
      Rails.logger.warn "Login failed: User not found for email #{@params[:email]}"
      raise
    rescue Exceptions::InvalidCredentialsError => e
      Rails.logger.warn "Login failed: Invalid credentials for email #{@params[:email]}"
      raise
    rescue => e
      Rails.logger.error "Unexpected error during login for #{@params[:email]}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

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
  end
end