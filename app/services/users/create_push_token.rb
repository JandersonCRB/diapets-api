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
      Rails.logger.info("Push token process completed successfully for user: #{user.id}")

      result
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
      Rails.logger.info("Creating/finding push token for user: #{user.id}")
      Rails.logger.debug("Token value: #{@params[:token]&.slice(0, 10)}...")

      begin
        # Use find_or_create_by to ensure uniqueness per user-token combination
        push_token = PushToken.find_or_create_by!(user: user, token: @params[:token]) do |_pt|
          Rails.logger.info("Creating new push token record for user: #{user.id}")
        end

        if push_token.persisted? && !push_token.previously_new_record?
          Rails.logger.info("Found existing push token for user: #{user.id}")
        else
          Rails.logger.info("Successfully created new push token for user: #{user.id}")
        end

        Rails.logger.debug("Push token ID: #{push_token.id}")
        push_token
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to create push token for user #{user.id}: #{e.message}")
        raise e
      rescue StandardError => e
        Rails.logger.error("Unexpected error creating push token for user #{user.id}: #{e.message}")
        raise e
      end
    end
  end
end
