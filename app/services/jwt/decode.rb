# frozen_string_literal: true

# Service class for decoding JSON Web Tokens (JWT)
# This service handles the secure decoding and validation of JWT tokens
# used for user authentication and authorization
module Jwt
  # Service class for decoding and validating JWT tokens
  class Decode
    prepend SimpleCommand
    include Helpers::EnvHelpers

    # Initialize the JWT decoder with token and verification options
    # @param token [String] The JWT token to decode
    # @param verify [Boolean] Whether to verify the token signature (default: true)
    def initialize(token, verify: true)
      Rails.logger.info('Initializing JWT Decode service')
      Rails.logger.debug("Token provided: #{token ? 'Yes' : 'No'}")
      Rails.logger.debug("Token length: #{token&.length || 0} characters")
      Rails.logger.debug("Verification enabled: #{verify}")

      @token = token
      @verify = verify
    end

    # Main method to decode the JWT token
    # Validates the token signature and returns the decoded payload
    # @return [Hash] The decoded token payload with symbolized keys
    # @raise [Exceptions::InvalidTokenError] If token is invalid or verification fails
    def call
      Rails.logger.info('Starting JWT token decoding process')
      Rails.logger.debug('Using HS256 algorithm for token verification')
      Rails.logger.debug("JWT secret configured: #{jwt_secret ? 'Yes' : 'No'}")

      begin
        # Decode the JWT token using the configured secret and algorithm
        decoded = JWT.decode(token, jwt_secret, verify, { algorithm: 'HS256' })[0]
        Rails.logger.debug("Raw decoded token: #{decoded}")

        # Validate that the decoded token contains data
        if decoded.blank?
          Rails.logger.error('Decoded token is blank or empty')
          raise Exceptions::InvalidTokenError.new, 'Invalid Token'
        end

        # Convert string keys to symbols for consistent access patterns
        symbolized_payload = decoded.symbolize_keys
        Rails.logger.info('Successfully decoded JWT token')
        Rails.logger.debug("Token payload keys: #{symbolized_payload.keys}")
        Rails.logger.debug("User ID from token: #{symbolized_payload[:user_id]}")

        symbolized_payload
      rescue JWT::VerificationError => e
        Rails.logger.error("JWT verification failed: #{e.message}")
        Rails.logger.debug("Token verification error details: #{e.class}")
        raise Exceptions::InvalidTokenError.new, 'Invalid Token'
      rescue JWT::DecodeError => e
        Rails.logger.error("JWT decode error: #{e.message}")
        Rails.logger.debug("Token decode error details: #{e.class}")
        raise Exceptions::InvalidTokenError.new, 'Invalid Token'
      rescue StandardError => e
        Rails.logger.error("Unexpected error during JWT decoding: #{e.message}")
        Rails.logger.debug("Error class: #{e.class}")
        raise Exceptions::InvalidTokenError.new, 'Invalid Token'
      end
    end

    private

    # Accessor methods for instance variables
    # @return [String] The JWT token to decode
    # @return [Boolean] Whether to verify the token signature
    attr_reader :token, :verify
  end
end
