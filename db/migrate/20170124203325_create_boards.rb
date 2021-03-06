class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.belongs_to :game
      t.belongs_to :user
      t.integer :x
      t.integer :y
      t.belongs_to :ship
      t.boolean :is_bombed
      t.datetime :time_bombed
      t.timestamps
    end
  end
end
