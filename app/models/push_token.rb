# frozen_string_literal: true

# Stores Firebase push notification tokens for users' mobile devices.
# These tokens are used to send insulin reminders and other notifications
# to users' mobile applications.
class PushToken < ApplicationRecord
  belongs_to :user
end
