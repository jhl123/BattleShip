class Board < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :game

  MAX_ROWS = 10
  MAX_COLUMNS = 10

  def mark_as_bombed
    self.is_bombed = true
    self.time_bombed = DateTime.now
    self.save

    ApplicationController.helpers.update_cache(self)
  end

  def ship_exists?
    return !self.ship_id.nil?
  end

  def ship_sunk?
    if !self.ship_exists?
      return false
    end

    game_cache = get_cache(self.game_id)
    board = game_cache[self.user_id]

    board.each do |rows|
      rows.each do |tile|
        if tile.ship_exists? && self.ship_id == tile.ship_id && !tile.is_bombed
          return false
        end
      end
    end

    return true
  end

  def self.create_new_boards(game)
    if game.user_1_id.nil? || game.user_2_id.nil?
      raise "Game does not have both users ready"
    end
    if !game.has_started
      raise "Game hasn't started yet"
    end

    self.create_board(game.id, game.user_1_id)
    self.create_board(game.id, game.user_2_id)
    ApplicationController.helpers.add_to_cache(game)
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
