class DeleteInsulinAlarms < ActiveRecord::Migration[7.1]
  def change
    drop_table :insulin_alarm_responsibles
    drop_table :insulin_alarms
  end
end
