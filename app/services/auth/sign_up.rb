# frozen_string_literal: true

module Auth
  # Service class responsible for user registration and account creation
  # Validates input parameters, creates new user accounts, and generates initial JWT tokens
  # Performs comprehensive validation of email, password, and name requirements
  class SignUp
    prepend SimpleCommand
    include Helpers::AuthHelpers

    # Initialize the sign-up service with registration parameters
    # @param params [Hash] Registration parameters containing user information
    def initialize(params)
      Rails.logger.info "Auth::SignUp initialized for email: #{params[:email]}"
      @params = params
    end

    # Main execution method that orchestrates the user registration process
    # Validates all input parameters, creates user account, and generates auth token
    # @return [Hash] Hash containing authentication token and created user object
    # @raise [Exceptions::UnprocessableEntityError] If validation fails
    def call
      Rails.logger.info "Starting user registration process for email: #{@params[:email]}"

      # Perform comprehensive input validation
      validate_email
      Rails.logger.debug 'Email validation passed'

      validate_password
      Rails.logger.debug 'Password validation passed'

      validate_names
      Rails.logger.debug 'Name validation passed'

      # Create the new user account
      user = create_user
      Rails.logger.info "User account created successfully: #{user.email} (ID: #{user.id})"

      # Generate authentication token for immediate login
      token = generate_token(user)
      Rails.logger.info "Authentication token generated for new user: #{user.email}"

      # Return registration response
      registration_response = { token: token, user: user }
      Rails.logger.info "User registration completed successfully for: #{user.email}"

      registration_response
    rescue Exceptions::UnprocessableEntityError => e
      Rails.logger.warn "User registration failed for #{@params[:email]}: #{e.message}"
      raise
    rescue StandardError => e
      Rails.logger.error "Unexpected error during user registration for #{@params[:email]}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

    # Validate email address format and uniqueness
    # Checks for presence, valid format, and ensures email is not already registered
    # @raise [Exceptions::UnprocessableEntityError] If email validation fails
    def validate_email
      Rails.logger.debug "Validating email: #{@params[:email]}"

      # Check if email is present
      if @params[:email].blank?
        Rails.logger.debug 'Email validation failed: email is blank'
        raise Exceptions::UnprocessableEntityError.new('Email is required', detailed_code: 'EMAIL_REQUIRED')
      end

      # Validate email format using URI regexp
      unless @params[:email] =~ URI::MailTo::EMAIL_REGEXP
        Rails.logger.debug "Email validation failed: invalid format for #{@params[:email]}"
        raise Exceptions::UnprocessableEntityError.new('Email is invalid', detailed_code: 'INVALID_EMAIL')
      end

      # Check if email is already registered
      if User.exists?(email: @params[:email])
        Rails.logger.debug "Email validation failed: email already exists #{@params[:email]}"
        raise Exceptions::UnprocessableEntityError.new('Email is already taken', detailed_code: 'EMAIL_TAKEN')
      end

      Rails.logger.debug "Email validation successful for: #{@params[:email]}"
    end

    # Create a new user record with validated parameters
    # Uses the sanitized user parameters to create the account
    # @return [User] The newly created user record
    def create_user
      Rails.logger.debug "Creating user account with parameters: #{user_params.except(:password)}"

      # Create the user with validated parameters
      user = User.create(user_params)

      Rails.logger.info "User account created: #{user.first_name} #{user.last_name} <#{user.email}>"
      user
    end

    # Validate password meets minimum security requirements
    # Ensures password is sufficiently long for security
    # @raise [Exceptions::UnprocessableEntityError] If password validation fails
    def validate_password
      Rails.logger.debug 'Validating password requirements'

      # Check minimum password length
      if @params[:password].length < 6
        Rails.logger.debug "Password validation failed: password too short (#{@params[:password].length} characters)"
        raise Exceptions::UnprocessableEntityError.new('Password is too short', detailed_code: 'SHORT_PASSWORD')
      end

      Rails.logger.debug "Password validation successful (length: #{@params[:password].length})"
    end

    # Validate first and last name requirements
    # Ensures both names are present and meet minimum length requirements
    # @raise [Exceptions::UnprocessableEntityError] If name validation fails
    def validate_names
      Rails.logger.debug 'Validating name requirements'

      # Validate first name presence
      if @params[:first_name].blank?
        Rails.logger.debug 'Name validation failed: first name is blank'
        raise Exceptions::UnprocessableEntityError.new('First name is required', detailed_code: 'FIRST_NAME_REQUIRED')
      end

      # Validate first name length
      if @params[:first_name].length < 2
        Rails.logger.debug "Name validation failed: first name too short (#{@params[:first_name].length} characters)"
        raise Exceptions::UnprocessableEntityError.new('First name is too short', detailed_code: 'FIRST_NAME_SHORT')
      end

      # Validate last name presence
      if @params[:last_name].blank?
        Rails.logger.debug 'Name validation failed: last name is blank'
        raise Exceptions::UnprocessableEntityError.new('Last name is required', detailed_code: 'LAST_NAME_REQUIRED')
      end

      # Validate last name length
      if @params[:last_name].length < 2
        Rails.logger.debug "Name validation failed: last name too short (#{@params[:last_name].length} characters)"
        raise Exceptions::UnprocessableEntityError.new('Last name is too short', detailed_code: 'LAST_NAME_SHORT')
      end

      Rails.logger.debug "Name validation successful: #{@params[:first_name]} #{@params[:last_name]}"
    end

    # Build sanitized user parameters for account creation
    # Extracts and organizes the validated input parameters
    # @return [Hash] Hash of parameters for user creation
    def user_params
      {
        email: @params[:email],
        password: @params[:password],
        first_name: @params[:first_name],
        last_name: @params[:last_name]
      }
    end
  end
end
