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
        Rails.logger.debug "Bearer token extracted from Authorization header (length: #{@access_token.length})"
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

      # Validate that a token is present
      validate_access_token
      Rails.logger.debug 'Access token validation passed'

      # Decode the JWT token to extract user information
      Rails.logger.debug 'Decoding JWT token'
      decoded_result = Jwt::Decode.call(access_token).result

      Rails.logger.info 'JWT token successfully decoded and authorized'
      Rails.logger.debug "Decoded token contains user_id: #{decoded_result[:user_id]}"

      decoded_result
    rescue Exceptions::InvalidTokenError => e
      Rails.logger.error "Token authorization failed: #{e.message}"
      raise
    rescue StandardError => e
      Rails.logger.error "Unexpected error during token authorization: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
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

    # Reader method for the extracted access token
    # @return [String, nil] The Bearer token extracted from headers
    attr_reader :access_token
  end
end
