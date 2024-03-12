class CreateInsulinAlarmResponsibles < ActiveRecord::Migration[7.1]
  def change
    create_table :insulin_alarm_responsibles, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :insulin_alarm, null: false, foreign_key: true

      t.index [:user_id, :insulin_alarm_id], unique: true

      t.timestamps
    end
  end
end
