# frozen_string_literal: true

# Service class for creating and managing push tokens for users
# This service handles the registration of Firebase Cloud Messaging (FCM) tokens
# for users to enable push notifications
module Users
  # Service class for creating and managing user push tokens
  class CreatePushToken
    prepend SimpleCommand

    # Initialize the service with decoded JWT token and request parameters
    # @param decoded_token [Hash] Decoded JWT token containing user information
    # @param params [Hash] Request parameters containing the push token
    def initialize(decoded_token, params)
      Rails.logger.info('Initializing CreatePushToken service')
      Rails.logger.debug("Decoded token user_id: #{decoded_token[:user_id]}")
      Rails.logger.debug("Push token to register: #{params[:token]&.slice(0, 10)}...")

      @decoded_token = decoded_token
      @params = params
    end

    # Main method to create or update the push token for the user
    # Returns the created/found push token record
    def call
      Rails.logger.info('Starting push token creation/update process')
      Rails.logger.info("Processing push token for user: #{user.id}")

      result = create_push_token(user)
      log_success_and_return_result(result)
    end

    private

    # Retrieve the user from the database using the user_id from the decoded token
    # Uses memoization to avoid multiple database queries
    # @return [User] The user associated with the decoded token
    def user
      Rails.logger.debug("Looking up user with ID: #{@decoded_token[:user_id]}")

      @user ||= begin
        found_user = User.find(@decoded_token[:user_id])
        Rails.logger.info("Found user: #{found_user.email} (ID: #{found_user.id})")
        found_user
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("User not found with ID: #{@decoded_token[:user_id]}")
        raise e
      end
    end

    # Create or find existing push token for the user
    # Uses find_or_create_by to prevent duplicate tokens for the same user
    # @param user [User] The user to create the push token for
    # @return [PushToken] The created or existing push token record
    def create_push_token(user)
      log_push_token_creation_start(user)

      begin
        push_token = find_or_create_token_for_user(user)
        log_token_creation_result(push_token, user)
        push_token
      rescue StandardError => e
        handle_push_token_creation_error(user, e)
      end
    end

    # Log the start of push token creation
    # @param user [User] The user for whom the token is being created
    def log_push_token_creation_start(user)
      Rails.logger.info("Creating/finding push token for user: #{user.id}")
      Rails.logger.debug("Token value: #{@params[:token]&.slice(0, 10)}...")
    end

    # Handle push token creation errors
    # @param user [User] The user for whom token creation failed
    # @param error [StandardError] The error that occurred
    # @raise [StandardError] Re-raises the original error
    def handle_push_token_creation_error(user, error)
      if error.is_a?(ActiveRecord::RecordInvalid)
        Rails.logger.error("Failed to create push token for user #{user.id}: #{error.message}")
      else
        Rails.logger.error("Unexpected error creating push token for user #{user.id}: #{error.message}")
      end
      raise error
    end

    # Finds or creates a push token for the user
    # @param user [User] The user to create the push token for
    # @return [PushToken] The created or existing push token record
    def find_or_create_token_for_user(user)
      PushToken.find_or_create_by!(user: user, token: @params[:token]) do |_pt|
        Rails.logger.info("Creating new push token record for user: #{user.id}")
      end
    end

    # Logs the result of token creation and returns the result
    # @param push_token [PushToken] The push token record
    # @param user [User] The user associated with the token
    def log_token_creation_result(push_token, user)
      if push_token.persisted? && !push_token.previously_new_record?
        Rails.logger.info("Found existing push token for user: #{user.id}")
      else
        Rails.logger.info("Successfully created new push token for user: #{user.id}")
      end

      Rails.logger.debug("Push token ID: #{push_token.id}")
    end

    # Logs success message and returns the result
    # @param result [PushToken] The push token result
    # @return [PushToken] The push token result
    def log_success_and_return_result(result)
      Rails.logger.info("Push token process completed successfully for user: #{user.id}")
      result
    end
  end
end
