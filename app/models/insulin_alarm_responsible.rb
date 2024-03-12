class InsulinAlarmResponsible < ApplicationRecord
  belongs_to :user
  belongs_to :insulin_alarm
end
