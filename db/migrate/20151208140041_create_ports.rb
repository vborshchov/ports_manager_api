class CreatePorts < ActiveRecord::Migration
  def change
    create_table :ports do |t|
      t.string :name
      t.string :state
      t.string :description
      t.references :node, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.boolean :reserved, default: false

      t.timestamps null: false
    end
  end
end
