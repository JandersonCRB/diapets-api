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
      Rails.logger.info "Generating JWT token for user ID: #{user.id}"

      # Create payload with user identifier
      payload = { user_id: user.id }
      Rails.logger.debug "JWT payload: #{payload}"

      # Encode the token using JWT service
      token = Jwt::Encode.call(payload).result

      Rails.logger.info "Successfully generated JWT token for user #{user.id}"
      Rails.logger.debug "Generated token length: #{token&.length || 0} characters"

      token
    rescue StandardError => e
      Rails.logger.error "Failed to generate JWT token for user #{user.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
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

      Rails.logger.debug "JWT secret successfully retrieved (length: #{secret.length} characters)"
      secret
    end
  end
end
