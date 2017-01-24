class AddNextTurnUserIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :next_turn_user_id, :integer
  end
end
