class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :nodes, :fttb, :node_type
  end
end
