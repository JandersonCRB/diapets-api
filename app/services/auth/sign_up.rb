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

      validate_all_inputs
      user = create_new_user
      build_registration_response(user)
    rescue Exceptions::UnprocessableEntityError => e
      handle_validation_error(e)
    rescue StandardError => e
      handle_unexpected_error(e)
    end

    private

    # Validate email address format and uniqueness
    # Checks for presence, valid format, and ensures email is not already registered
    # @raise [Exceptions::UnprocessableEntityError] If email validation fails
    def validate_email
      Rails.logger.debug "Validating email: #{@params[:email]}"

      validate_email_presence
      validate_email_format
      validate_email_uniqueness

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

      validate_first_name
      validate_last_name

      Rails.logger.debug "Name validation successful: #{@params[:first_name]} #{@params[:last_name]}"
    end

    # Perform comprehensive validation of all input parameters
    # Validates email, password, and name requirements in sequence
    # @raise [Exceptions::UnprocessableEntityError] If any validation fails
    def validate_all_inputs
      validate_email
      Rails.logger.debug 'Email validation passed'

      validate_password
      Rails.logger.debug 'Password validation passed'

      validate_names
      Rails.logger.debug 'Name validation passed'
    end

    # Create new user account with validated parameters
    # Combines user creation and logging into a single operation
    # @return [User] The newly created user record
    def create_new_user
      user = create_user
      Rails.logger.info "User account created successfully: #{user.email} (ID: #{user.id})"
      user
    end

    # Build successful registration response with token and user data
    # Creates the response hash and generates authentication token
    # @param user [User] The newly created user record
    # @return [Hash] Hash containing authentication token and user object
    def build_registration_response(user)
      token = generate_token(user)
      Rails.logger.info "Authentication token generated for new user: #{user.email}"

      registration_response = { token: token, user: user }
      Rails.logger.info "User registration completed successfully for: #{user.email}"

      registration_response
    end

    # Validate first name presence and length requirements
    # Ensures first name is present and meets minimum length
    # @raise [Exceptions::UnprocessableEntityError] If first name validation fails
    def validate_first_name
      # Validate first name presence
      if @params[:first_name].blank?
        Rails.logger.debug 'Name validation failed: first name is blank'
        raise Exceptions::UnprocessableEntityError.new('First name is required', detailed_code: 'FIRST_NAME_REQUIRED')
      end

      # Validate first name length
      return unless @params[:first_name].length < 2

      Rails.logger.debug "Name validation failed: first name too short (#{@params[:first_name].length} characters)"
      raise Exceptions::UnprocessableEntityError.new('First name is too short', detailed_code: 'FIRST_NAME_SHORT')
    end

    # Validate last name presence and length requirements
    # Ensures last name is present and meets minimum length
    # @raise [Exceptions::UnprocessableEntityError] If last name validation fails
    def validate_last_name
      # Validate last name presence
      if @params[:last_name].blank?
        Rails.logger.debug 'Name validation failed: last name is blank'
        raise Exceptions::UnprocessableEntityError.new('Last name is required', detailed_code: 'LAST_NAME_REQUIRED')
      end

      # Validate last name length
      return unless @params[:last_name].length < 2

      Rails.logger.debug "Name validation failed: last name too short (#{@params[:last_name].length} characters)"
      raise Exceptions::UnprocessableEntityError.new('Last name is too short', detailed_code: 'LAST_NAME_SHORT')
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

    # Handle validation errors during registration
    # @param error [Exceptions::UnprocessableEntityError] The validation error
    # @raise [Exceptions::UnprocessableEntityError] Re-raises the error after logging
    def handle_validation_error(error)
      Rails.logger.warn "User registration failed for #{@params[:email]}: #{error.message}"
      raise error
    end

    # Handle unexpected errors during registration
    # @param error [StandardError] The unexpected error that occurred
    # @raise [StandardError] Re-raises the error after logging
    def handle_unexpected_error(error)
      Rails.logger.error "Unexpected error during user registration for #{@params[:email]}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise error
    end

    # Validate that email is present and not blank
    # @raise [Exceptions::UnprocessableEntityError] If email is blank
    def validate_email_presence
      return if @params[:email].present?

      Rails.logger.debug 'Email validation failed: email is blank'
      raise Exceptions::UnprocessableEntityError.new('Email is required', detailed_code: 'EMAIL_REQUIRED')
    end

    # Validate email format using URI regexp
    # @raise [Exceptions::UnprocessableEntityError] If email format is invalid
    def validate_email_format
      return if @params[:email] =~ URI::MailTo::EMAIL_REGEXP

      Rails.logger.debug "Email validation failed: invalid format for #{@params[:email]}"
      raise Exceptions::UnprocessableEntityError.new('Email is invalid', detailed_code: 'INVALID_EMAIL')
    end

    # Validate that email is not already registered
    # @raise [Exceptions::UnprocessableEntityError] If email already exists
    def validate_email_uniqueness
      return unless User.exists?(email: @params[:email])

      Rails.logger.debug "Email validation failed: email already exists #{@params[:email]}"
      raise Exceptions::UnprocessableEntityError.new('Email is already taken', detailed_code: 'EMAIL_TAKEN')
    end
  end
end
