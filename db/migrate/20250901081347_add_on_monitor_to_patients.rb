class AddOnMonitorToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :on_monitor, :boolean, default: false
  end
end