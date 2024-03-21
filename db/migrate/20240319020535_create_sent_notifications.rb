class CreateSentNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :sent_notifications do |t|
      t.references :pet, null: false, foreign_key: true
      t.integer :minutes_alarm
      t.references :last_insulin, null: false, foreign_key: { to_table: :insulin_applications }

      t.timestamps
    end
  end
end
