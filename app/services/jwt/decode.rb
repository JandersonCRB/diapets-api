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
      log_initialization_info
      validate_token
      process_payload(decode_jwt_token)
    end

    private

    # Log initialization information for debugging
    def log_initialization_info
      Rails.logger.info('Starting JWT token decoding process')
      Rails.logger.debug('Using HS256 algorithm for token verification')
      Rails.logger.debug("JWT secret configured: #{jwt_secret ? 'Yes' : 'No'}")
    end

    # Validate the token by checking if it exists and is not blank
    # @raise [Exceptions::InvalidTokenError] If token is invalid
    def validate_token
      # Token presence validation could be added here if needed
      # Currently relying on JWT library to handle missing tokens
    end

    # Decode the JWT token and handle any errors that occur during decoding
    # @return [Hash] The raw decoded token payload
    # @raise [Exceptions::InvalidTokenError] If token decoding fails
    def decode_jwt_token
      decoded = perform_jwt_decode
      validate_decoded_token(decoded)
      decoded
    rescue JWT::VerificationError, JWT::DecodeError => e
      handle_jwt_error(e)
    rescue StandardError => e
      handle_unexpected_decode_error(e)
    end

    # Process the decoded payload by converting keys to symbols and logging success
    # @param decoded [Hash] The raw decoded token payload
    # @return [Hash] The processed payload with symbolized keys
    def process_payload(decoded)
      # Convert string keys to symbols for consistent access patterns
      symbolized_payload = decoded.symbolize_keys
      Rails.logger.info('Successfully decoded JWT token')
      Rails.logger.debug("Token payload keys: #{symbolized_payload.keys}")
      Rails.logger.debug("User ID from token: #{symbolized_payload[:user_id]}")

      symbolized_payload
    end

    # Perform the actual JWT decoding operation
    # @return [Hash] The raw decoded token payload
    def perform_jwt_decode
      # Decode the JWT token using the configured secret and algorithm
      decoded = JWT.decode(token, jwt_secret, verify, { algorithm: 'HS256' })[0]
      Rails.logger.debug("Raw decoded token: #{decoded}")
      decoded
    end

    # Validate that the decoded token contains data
    # @param decoded [Hash] The decoded token payload
    # @raise [Exceptions::InvalidTokenError] If token is blank or empty
    def validate_decoded_token(decoded)
      return if decoded.present?

      Rails.logger.error('Decoded token is blank or empty')
      raise Exceptions::InvalidTokenError.new, 'Invalid Token'
    end

    # Handle JWT-specific errors (verification and decoding errors)
    # @param error [Exception] The JWT error that occurred
    # @raise [Exceptions::InvalidTokenError] Always raises with generic error message
    def handle_jwt_error(error)
      Rails.logger.error("JWT error: #{error.message}")
      Rails.logger.debug("JWT error details: #{error.class}")
      raise Exceptions::InvalidTokenError.new, 'Invalid Token'
    end

    # Handle unexpected errors during token decoding
    # @param error [StandardError] The unexpected error that occurred
    # @raise [Exceptions::InvalidTokenError] Always raises with generic error message
    def handle_unexpected_decode_error(error)
      Rails.logger.error("Unexpected error during JWT decoding: #{error.message}")
      Rails.logger.debug("Error class: #{error.class}")
      raise Exceptions::InvalidTokenError.new, 'Invalid Token'
    end

    # Accessor methods for instance variables
    # @return [String] The JWT token to decode
    # @return [Boolean] Whether to verify the token signature
    attr_reader :token, :verify
  end
end
