# frozen_string_literal: true

# Represents scheduled insulin reminder alarms for diabetic pets.
# Each alarm belongs to a specific pet and can have multiple responsible users
# who will receive notifications when the alarm triggers.
class InsulinAlarm < ApplicationRecord
  belongs_to :pet

  has_many :insulin_alarm_responsible
  has_many :responsibles, through: :insulin_alarm_responsible, source: :user

  validates :hour, :minute, :status, presence: true
end
