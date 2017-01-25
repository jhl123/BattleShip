class Board < ActiveRecord::Base
  belongs_to :game

  MAX_ROWS = 10
  MAX_COLUMNS = 10

  def mark_as_bombed
    self.is_bombed = true
    self.time_bombed = DateTime.now
    self.save

    board_cache = Rails.cache.fetch('board_cache')
    board_cache[self.game_id][self.user_id][self.x][self.y] = self
    Rails.cache.write('board_cache', board_cache)
  end

  def ship_exists?
    return !self.ship_id.nil?
  end

  def self.create_new_boards(game)
    if game.user_1_id.nil? || game.user_2_id.nil?
      raise "Game does not have both users ready"
    end
    if !game.has_started
      raise "Game hasn't started yet"
    end
    

    board_cache = Rails.cache.fetch('board_cache')
    if board_cache.nil?
      board_cache = Hash.new
    end

    board_cache[game.id] = Hash.new
    board_cache[game.id][game.user_1_id] = self.create_board(game.id, game.user_1_id)
    board_cache[game.id][game.user_2_id] = self.create_board(game.id, game.user_2_id)
    Rails.cache.write('board_cache', board_cache)
  end

  def self.load_game(game_id, user_id)
    board = self.create_empty_board
    board_tiles = Board.where(game_id: game_id, user_id: user_id)

    board_tiles.each do |tile|
      board[tile.x][tile.y] = tile
    end

    return board
  end

  private
    def self.create_board(game_id, user_id)
      board_array = self.create_empty_board_pieces(game_id,user_id)
      self.place_all_ships_to_board(board_array)
      return board_array
    end

    def self.create_empty_board_pieces(game_id, user_id)
      board_array = self.create_empty_board
      (0..MAX_ROWS - 1).each do |x|
        (0..MAX_COLUMNS - 1).each do |y|
          board_array[x][y] = Board.create(game_id: game_id, user_id: user_id, x: x, y: y)
        end
      end
      return board_array
    end
  
    def self.create_empty_board
      return Array.new(MAX_ROWS){Array.new(MAX_COLUMNS)}
    end

    def self.place_all_ships_to_board(board_array)
      ships = Ship.all
      ships.each do |ship|
        ship_placed = false
        while !ship_placed
          rand_x = rand(MAX_ROWS - 1)
          rand_y = rand(MAX_COLUMNS - 1)
          orientation = self.legal_ship_orientation(board_array, ship.length, rand_x, rand_y)
          if !orientation.nil?
            self.place_ship(board_array, ship, rand_x, rand_y, orientation)
            ship_placed = true
          end
        end
      end
    end

    def self.legal_ship_orientation(board_array, length, x, y)
      orientation = rand(1) == 0 ? "horizontal" : "vertical"

      if self.is_orientation_legal(board_array, length, x, y, orientation)
        return orientation
      end

      second_orientation = orientation == "horizontal" ? "vertical" : "horizontal"

      if self.is_orientation_legal(board_array, length, x, y, second_orientation)
        return second_orientation
      end

      return nil
    end

    def self.is_orientation_legal(board_array, length, x, y, orientation)
      (0..length - 1).each do |i|
        if orientation == "horizontal" && (i + x >=  MAX_ROWS || !board_array[x + i][y].ship_id.nil?)
          return false
        elsif i + y >=  MAX_COLUMNS || !board_array[x][y + i].ship_id.nil?
          return false
        end
      end

      return true
    end

    def self.place_ship(board_array, ship, x, y, orientation)
      (0..ship.length - 1).each do |i|
        if orientation == "horizontal"
          board_array[x + i][y].ship_id = ship.id
          board_array[x + i][y].save
        elsif
          board_array[x][y + i].ship_id = ship.id
          board_array[x][y + i].save
        end
      end
    end
end
