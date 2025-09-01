class CreatePatients < ActiveRecord::Migration[6.1]
  def change
    create_table :patients do |t|
      t.string :full_name, null: false
      t.date :date_of_birth, null: false
      t.datetime :admission_time, null: false
      t.timestamps
    end
  end
end