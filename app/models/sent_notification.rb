# frozen_string_literal: true

# Tracks push notifications that have been sent to users about their pets.
# This model helps prevent duplicate notifications and provides an audit trail
# of when and what notifications were sent for each pet.
class SentNotification < ApplicationRecord
  belongs_to :pet
end
