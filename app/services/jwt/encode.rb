# Service class for encoding JSON Web Tokens (JWT)
# This service handles the secure creation and signing of JWT tokens
# used for user authentication and session management
module Jwt
  class Encode
    prepend SimpleCommand
    include Helpers::EnvHelpers

    # Initialize the JWT encoder with payload data
    # @param payload [Hash] The data to encode into the JWT token
    def initialize(payload)
      Rails.logger.info("Initializing JWT Encode service")
      Rails.logger.debug("Payload provided: #{payload ? 'Yes' : 'No'}")
      Rails.logger.debug("Payload keys: #{payload&.keys}")
      Rails.logger.debug("User ID in payload: #{payload[:user_id] || payload['user_id']}")
      
      @payload = payload
    end

    # Main method to encode the payload into a JWT token
    # Signs the token using the configured secret and HS256 algorithm
    # @return [String] The encoded JWT token
    def call
      Rails.logger.info("Starting JWT token encoding process")
      Rails.logger.debug("Using HS256 algorithm for token signing")
      Rails.logger.debug("JWT secret configured: #{jwt_secret ? 'Yes' : 'No'}")
      Rails.logger.debug("Payload to encode: #{@payload}")
      
      begin
        # Encode the payload using JWT with HS256 algorithm
        encoded_token = JWT.encode(payload, jwt_secret, 'HS256')
        
        Rails.logger.info("Successfully encoded JWT token")
        Rails.logger.debug("Generated token length: #{encoded_token.length} characters")
        Rails.logger.debug("Token preview: #{encoded_token[0..20]}...")
        
        encoded_token
        
      rescue StandardError => e
        Rails.logger.error("Failed to encode JWT token: #{e.message}")
        Rails.logger.debug("Error class: #{e.class}")
        Rails.logger.debug("Payload causing error: #{@payload}")
        raise e
      end
    end

    private

    # Accessor method for the payload instance variable
    # @return [Hash] The payload data to be encoded into the JWT token
    attr_reader :payload
  end
end