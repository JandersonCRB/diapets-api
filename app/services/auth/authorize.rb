# frozen_string_literal: true

module Auth
  # Service class responsible for authorizing requests via JWT tokens
  # Extracts and validates Bearer tokens from request headers
  # Decodes valid tokens to extract user information for authorization
  class Authorize
    prepend SimpleCommand

    # Initialize the authorization service with request headers
    # Extracts the Bearer token from the Authorization header
    # @param headers [Hash] HTTP request headers containing authorization information
    def initialize(headers)
      Rails.logger.info 'Auth::Authorize initialized for request authorization'

      # Extract Bearer token from Authorization header
      @access_token = headers['authorization']&.split('Bearer ')&.last

      # Log token presence (without exposing the actual token)
      if @access_token.present?
        Rails.logger.debug { "Bearer token extracted from Authorization header (length: #{@access_token.length})" }
      else
        Rails.logger.warn 'No Bearer token found in Authorization header'
      end
    end

    # Main execution method that validates and decodes the JWT token
    # Performs token validation and returns the decoded payload
    # @return [Hash] The decoded JWT payload containing user information
    # @raise [Exceptions::InvalidTokenError] If token is missing or invalid
    def call
      Rails.logger.info 'Starting JWT token authorization process'

      validate_access_token
      decoded_result = decode_token
      log_success(decoded_result)

      decoded_result
    rescue Exceptions::InvalidTokenError => e
      handle_token_error(e)
    rescue StandardError => e
      handle_unexpected_error(e)
    end

    private

    # Validate that an access token is present and not blank
    # Ensures a Bearer token was properly extracted from headers
    # @raise [Exceptions::InvalidTokenError] If token is missing or blank
    def validate_access_token
      Rails.logger.debug 'Validating access token presence'

      if access_token.blank?
        Rails.logger.warn 'Access token validation failed: token is blank or missing'
        raise Exceptions::InvalidTokenError
      end

      Rails.logger.debug 'Access token presence validation successful'
    end

    # Decode the JWT token to extract user information
    # @return [Hash] The decoded JWT payload
    def decode_token
      Rails.logger.debug 'Access token validation passed'
      Rails.logger.debug 'Decoding JWT token'
      Jwt::Decode.call(access_token).result
    end

    # Log successful token authorization
    # @param decoded_result [Hash] The decoded token payload
    def log_success(decoded_result)
      Rails.logger.info 'JWT token successfully decoded and authorized'
      Rails.logger.debug { "Decoded token contains user_id: #{decoded_result[:user_id]}" }
    end

    # Handle token-specific errors
    # @param error [Exceptions::InvalidTokenError] The token error
    def handle_token_error(error)
      Rails.logger.error "Token authorization failed: #{error.message}"
      raise
    end

    # Handle unexpected errors during authorization
    # @param error [StandardError] The unexpected error
    def handle_unexpected_error(error)
      Rails.logger.error "Unexpected error during token authorization: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      raise
    end

    # Reader method for the extracted access token
    # @return [String, nil] The Bearer token extracted from headers
    attr_reader :access_token
  end
end
