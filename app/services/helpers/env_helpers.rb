module Helpers
  # Helper module for environment variable management
  # Provides centralized access to required environment variables with validation
  # Ensures all critical configuration values are properly set
  module EnvHelpers
    
    # Retrieve and validate the JWT secret from environment variables
    # Used for signing and verifying JWT tokens across the application
    # @return [String] The JWT secret key
    # @raise [Exceptions::InternalServerError] If JWT_SECRET environment variable is not set
    def jwt_secret
      Rails.logger.debug "Retrieving JWT_SECRET environment variable"
      
      # Fetch the JWT secret from environment
      jwt = ENV.fetch('JWT_SECRET', nil)
      
      # Validate that the secret is configured
      if jwt.nil?
        Rails.logger.error "JWT_SECRET environment variable is not configured"
        raise Exceptions::InternalServerError.new("JWT_SECRET ENV VARIABLE NOT SET")
      end
      
      Rails.logger.debug "JWT_SECRET successfully retrieved (length: #{jwt.length} characters)"
      jwt
    end

    # Retrieve and validate the Firebase Cloud Messaging credentials path
    # Used for push notification services configuration
    # @return [String] The path to FCM credentials file
    # @raise [Exceptions::InternalServerError] If FCM_CRED_PATH environment variable is not set
    def fcm_cred_path
      Rails.logger.debug "Retrieving FCM_CRED_PATH environment variable"
      
      # Fetch the FCM credentials path from environment
      fcm = ENV.fetch('FCM_CRED_PATH', nil)
      
      # Validate that the path is configured
      if fcm.nil?
        Rails.logger.error "FCM_CRED_PATH environment variable is not configured"
        raise Exceptions::InternalServerError.new("FCM_CRED_PATH ENV VARIABLE NOT SET")
      end
      
      Rails.logger.debug "FCM_CRED_PATH successfully retrieved: #{fcm}"
      fcm
    end

    # Retrieve and validate the Firebase Cloud Messaging project ID
    # Used for identifying the FCM project for push notifications
    # @return [String] The FCM project ID
    # @raise [Exceptions::InternalServerError] If FCM_PROJECT_ID environment variable is not set
    def fcm_project_id
      Rails.logger.debug "Retrieving FCM_PROJECT_ID environment variable"
      
      # Fetch the FCM project ID from environment
      fcm = ENV.fetch('FCM_PROJECT_ID', nil)
      
      # Validate that the project ID is configured
      if fcm.nil?
        Rails.logger.error "FCM_PROJECT_ID environment variable is not configured"
        raise Exceptions::InternalServerError.new("FCM_PROJECT_ID ENV VARIABLE NOT SET")
      end
      
      Rails.logger.debug "FCM_PROJECT_ID successfully retrieved: #{fcm}"
      fcm
    end
  end
end
