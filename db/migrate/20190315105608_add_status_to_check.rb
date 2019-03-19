class AddStatusToCheck < ActiveRecord::Migration[5.2]
  def change
    # defaults to "down"
    add_column :checks, :status, :integer, default: 1, null: false
  end
end
