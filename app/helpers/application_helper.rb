module ApplicationHelper
  
  def get_cache(game_id)
    game_cache = Rails.cache.fetch("game-#{game_id}")
    if game_cache.nil?
      game = Game.find(game_id)
      game_cache = add_to_cache(game)
    end
    return game_cache
  end
  
  def add_to_cache(game)
    game_cache = Hash.new
    game_cache[game.user_1_id] = Board.load_game(game.id, game.user_1_id)
    game_cache[game.user_2_id] = Board.load_game(game.id, game.user_2_id)
    Rails.cache.write("game-#{game.id}", game_cache, :expires_in => 30.minutes)
    return game_cache
  end

  def update_cache(board)
    game_cache = Rails.cache.fetch("game-#{board.game_id}")
    game_cache[board.user_id][board.x][board.y] = board
    Rails.cache.write("game-#{board.game_id}", game_cache, :expires_in => 30.minutes)
  end

  def add_last_move_to_cache(user_id, board)
    Rails.cache.write("last-move-game-#{board.game_id}-user-#{user_id}", board, :expires_in => 30.minutes)
  end

  def get_last_move(game_id, user_id)
    return Rails.cache.fetch("last-move-game-#{game_id}-user-#{user_id}")
  end

  def is_game_complete?(board)
    game_cache = get_cache(board.game_id)
    board = game_cache[board.user_id]

    board.each do |rows|
      rows.each do |tile|
        if tile.ship_exists? && !tile.is_bombed
          return false
        end
      end
    end

    return true
  end
end
