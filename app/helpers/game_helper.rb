module GameHelper
  def get_most_recent_bomb_class(board, user_board)
    if board.nil? || user_board.nil? || board.id != user_board.id
      return ""
    end

    return "most-recent-bombed"
  end
end
