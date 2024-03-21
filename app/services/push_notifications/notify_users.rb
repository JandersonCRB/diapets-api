module PushNotifications
  class NotifyUsers
    prepend SimpleCommand
    include Helpers::EnvHelpers

    def initialize(push_tokens, title, body)
      @push_tokens = push_tokens
      @title = title
      @body = body

      @fcm = FCM.new(nil, fcm_cred_path, fcm_project_id)
    end

    def call
      Rails.logger.info("Sending push notifications")

      @push_tokens.each do |push_token|
        Rails.logger.info("Sending push notification to #{push_token}")
        send_notification(push_token, @title, @body)
      end
    end

    private

    def send_notification(push_token, title, body)
      message = {
        "token": push_token,
        "notification": { "title": title, "body": body }
      }
      @fcm.send_v1(message)
    end
  end
end