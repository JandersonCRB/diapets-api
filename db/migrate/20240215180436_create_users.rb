class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name, limit: 100
      t.string :last_name, limit: 300
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest

      t.timestamps
    end
  end
end
