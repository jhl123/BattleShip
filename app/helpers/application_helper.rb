module ApplicationHelper

  
  def get_cache(game_id)
    board_cache = Rails.cache.fetch('board_cache')
    if board_cache.nil?
      board_cache = initialize_cache
    end

    if board_cache[game_id].nil?
      game = Game.find(game_id)
      board_cache = add_to_cache(board_cache, game)
    end
    return board_cache
  end
  
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
    return board_cache
  end

  def is_game_complete?(board)
    board_cache = get_cache(board.game_id)
    board = board_cache[board.game_id][board.user_id]

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
