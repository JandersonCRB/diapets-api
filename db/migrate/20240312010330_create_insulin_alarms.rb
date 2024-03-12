class CreateInsulinAlarms < ActiveRecord::Migration[7.1]
  def change
    create_table :insulin_alarms do |t|
      t.integer :hour
      t.integer :minute
      t.string :title
      t.boolean :status
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
