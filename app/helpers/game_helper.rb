module GameHelper
  def get_most_recent_bomb_class(board, user_board)
    # puts "board: #{board.id}, #{user_board.id}"
    if board.nil? || user_board.nil? || board.id != user_board.id
      return ""
    end

    puts "FOUND........."
    return "most-recent-bombed"
  end
end
