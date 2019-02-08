class AddAvailableToCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :available, :boolean, default: false
  end
end
