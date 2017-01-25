module ApplicationHelper

  def initialize_cache
    board_cache = Hash.new
    Rails.cache.write('board_cache', board_cache)
    return board_cache
  end


  def add_to_cache(board_cache, game)
    if board_cache.nil?
      board_cache = initialize_cache
    end

    board_cache[game.id] = Hash.new
    
    board_cache[game.id][game.user_1_id] = Board.load_game(game.id, game.user_1_id)
    board_cache[game.id][game.user_2_id] = Board.load_game(game.id, game.user_2_id)
    Rails.cache.write('board_cache', board_cache)
  end
end
