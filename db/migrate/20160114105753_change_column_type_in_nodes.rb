class ChangeColumnTypeInNodes < ActiveRecord::Migration
  def up
    change_column :nodes, :node_type, :string
  end

  def down
    change_column :nodes, :node_type, :boolean
  end
end
