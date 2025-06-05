# frozen_string_literal: true

# Service class responsible for sending push notifications to users via Firebase Cloud Messaging (FCM)
# This service handles the delivery of push notifications to multiple users
module PushNotifications
  # Service class for sending push notifications via Firebase Cloud Messaging
  class NotifyUsers
    prepend SimpleCommand
    include Helpers::EnvHelpers

    # Initialize the notification service with push tokens and message content
    # @param push_tokens [Array<String>] Array of FCM push tokens to send notifications to
    # @param title [String] The notification title
    # @param body [String] The notification body text
    def initialize(push_tokens, title, body)
      Rails.logger.info("Initializing NotifyUsers service with #{push_tokens.count} tokens")
      Rails.logger.debug("Notification title: #{title}")
      Rails.logger.debug("Notification body: #{body}")

      @push_tokens = push_tokens
      @title = title
      @body = body

      # Initialize FCM client with credentials from environment helpers
      Rails.logger.info("Setting up FCM client with project ID: #{fcm_project_id}")
      @fcm = FCM.new(nil, fcm_cred_path, fcm_project_id)
    end

    # Main method to send notifications to all registered push tokens
    # Iterates through each token and sends individual notifications
    def call
      Rails.logger.info('Starting push notification delivery process')
      Rails.logger.info("Total notifications to send: #{@push_tokens.count}")

      success_count = 0
      error_count = 0

      @push_tokens.each_with_index do |push_token, index|
        Rails.logger.info("Sending notification #{index + 1}/#{@push_tokens.count} to token: #{push_token[0..8]}...")
        send_notification(push_token, @title, @body)
        Rails.logger.info("Successfully sent notification to token: #{push_token[0..8]}...")
        success_count += 1
      rescue StandardError => e
        Rails.logger.error("Failed to send notification to token #{push_token[0..8]}...: #{e.message}")
        error_count += 1
      end

      Rails.logger.info("Push notification delivery completed. Success: #{success_count}, Errors: #{error_count}")
    end

    private

    # Send a single push notification to a specific token
    # @param push_token [String] The FCM token to send the notification to
    # @param title [String] The notification title
    # @param body [String] The notification body
    # @return [Hash] FCM response
    def send_notification(push_token, title, body)
      Rails.logger.debug("Preparing FCM message for token: #{push_token[0..8]}...")

      # Construct FCM message payload according to FCM v1 API format
      message = {
        "token": push_token,
        "notification": { "title": title, "body": body }
      }

      Rails.logger.debug("FCM message payload: #{message}")

      # Send the notification via FCM v1 API
      response = @fcm.send_v1(message)
      Rails.logger.debug("FCM response: #{response}")

      response
    end
  end
end
