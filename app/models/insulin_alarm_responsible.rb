# frozen_string_literal: true

# Join table model that associates users with insulin alarms they are responsible for.
# This many-to-many relationship allows multiple users to be notified when
# a specific insulin alarm triggers for a pet.
class InsulinAlarmResponsible < ApplicationRecord
  belongs_to :user
  belongs_to :insulin_alarm
end
