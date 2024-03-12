class CreateInsulinApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :insulin_applications do |t|
      t.integer :glucose_level
      t.integer :insulin_units
      t.references :user, null: true, foreign_key: true
      t.datetime :application_time
      t.string :observations
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
