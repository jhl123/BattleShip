class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :user_1
      t.references :user_2
      t.references :winner

      t.timestamps
    end
  end
end
