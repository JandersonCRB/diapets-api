# frozen_string_literal: true

class InsulinAlarm < ApplicationRecord
  belongs_to :pet

  has_many :insulin_alarm_responsible
  has_many :responsibles, through: :insulin_alarm_responsible, source: :user

  validates :hour, :minute, :status, presence: true
end
