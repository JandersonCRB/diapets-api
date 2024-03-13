class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.string :name
      t.string :species
      t.date :birthdate
      t.integer :insulin_frequency

      t.timestamps
    end
  end
end
