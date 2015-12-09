class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :ip
      t.references :location, index: true, foreign_key: true
      t.string :type

      t.timestamps null: false
    end
  end
end
