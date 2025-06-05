# frozen_string_literal: true

module Helpers
  # Helper module for authentication-related operations
  # Provides JWT token generation and secret key management
  module AuthHelpers
    # Generate a JWT token for the given user
    # Encodes the user ID into a signed JWT token for authentication
    # @param user [User] The user object to generate a token for
    # @return [String] The encoded JWT token
    def generate_token(user)
      log_token_generation_start(user)
      payload = build_jwt_payload(user)
      token = encode_jwt_token(payload)
      log_token_generation_success(user, token)
      token
    rescue StandardError => e
      log_token_generation_error(user, e)
      raise
    end

    # Retrieve and validate the JWT secret from environment variables
    # Ensures the secret is properly configured for token signing/verification
    # @return [String] The JWT secret key
    # @raise [Exceptions::InternalServerError] If JWT_SECRET environment variable is not set
    def jwt_secret
      Rails.logger.debug 'Retrieving JWT secret from environment variables'

      # Fetch the secret from environment
      secret = ENV.fetch('JWT_SECRET', nil)

      # Validate that the secret is configured
      if secret.nil?
        Rails.logger.error 'JWT_SECRET environment variable is not set'
        raise Exceptions::InternalServerError, 'JWT_SECRET ENV VARIABLE NOT SET'
      end

      Rails.logger.debug { "JWT secret successfully retrieved (length: #{secret.length} characters)" }
      secret
    end

    private

    # Log the start of JWT token generation
    # @param user [User] The user for whom the token is being generated
    def log_token_generation_start(user)
      Rails.logger.info "Generating JWT token for user ID: #{user.id}"
    end

    # Build the JWT payload for the given user
    # @param user [User] The user object
    # @return [Hash] The JWT payload
    def build_jwt_payload(user)
      payload = { user_id: user.id }
      Rails.logger.debug { "JWT payload: #{payload}" }
      payload
    end

    # Encode the JWT token using the payload
    # @param payload [Hash] The JWT payload
    # @return [String] The encoded JWT token
    def encode_jwt_token(payload)
      Jwt::Encode.call(payload).result
    end

    # Log successful JWT token generation
    # @param user [User] The user for whom the token was generated
    # @param token [String] The generated token
    def log_token_generation_success(user, token)
      Rails.logger.info "Successfully generated JWT token for user #{user.id}"
      Rails.logger.debug { "Generated token length: #{token&.length || 0} characters" }
    end

    # Log JWT token generation error
    # @param user [User] The user for whom the token generation failed
    # @param error [StandardError] The error that occurred
    def log_token_generation_error(user, error)
      Rails.logger.error "Failed to generate JWT token for user #{user.id}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
    end
  end
end
