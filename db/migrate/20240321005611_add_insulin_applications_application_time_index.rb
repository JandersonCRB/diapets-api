class AddInsulinApplicationsApplicationTimeIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :insulin_applications, :application_time
  end
end
