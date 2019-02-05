class CreateChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :checks do |t|
      t.string :name
      t.integer :interval
      t.string :protocol
      t.string :url

      t.timestamps
    end
  end
end
