class AddModelToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :model, :string
    add_index :nodes, :model
    add_column :nodes, :fttb, :boolean, default: false
    add_index :nodes, :fttb
  end
end
