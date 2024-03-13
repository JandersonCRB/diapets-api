class CreatePetOwners < ActiveRecord::Migration[7.1]
  def change
    create_table :pet_owners do |t|
      t.references :pet, foreign_key: { to_table: :pets}
      t.references :owner, foreign_key: { to_table: :users }
      t.string :ownership_level


      t.timestamps
    end
    add_index :pet_owners, [:pet_id, :owner_id], unique: true
  end
end
