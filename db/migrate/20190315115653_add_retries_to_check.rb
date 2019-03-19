class AddRetriesToCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :retries, :integer, default: 0, null: false
  end
end
