class AlterColumnBoardXAndY < ActiveRecord::Migration
  def change
    change_column :boards, :x, :integer
    change_column :boards, :y, :integer
  end
end
