class GameController < ApplicationController
  include ApplicationHelper

  def index
    @user = User.where(username: session[:username]).take
    if params[:game_id].nil?
      @game = Game.create(user_1_id: @user.id)
      params[:game_id] = @game.id
      return
    end

    @game = Game.find(params[:game_id])
    if !@game.has_started && @user.id != @game.user_1_id
      @game.add_user(@user.id)
      @game.begin
      Board.create_new_boards(@game)
    end

    if @game.has_started
      if @user.id != @game.user_1_id && @user.id != @game.user_2_id
        render :partial => "game/incorrect_user"
        return
      end


      board_cache = Rails.cache.fetch('board_cache')
      if board_cache.nil?
        board_cache = Hash.new
      end

      if board_cache[@game.id].nil? || board_cache[@game.id][@user.id].nil?
        add_to_cache(board_cache, @game)
      end
      @player_board = Rails.cache.fetch('board_cache')[@game.id][@user.id]
      opponent_id = @game.user_1_id != @user.id ? @game.user_1_id : @game.user_2_id
      @opponent_user = User.find(opponent_id)
      @opponent_board = Rails.cache.fetch('board_cache')[@game.id][opponent_id]
      @total_ships = Ship.count
    end
  end

  def fire_missile
    @user = User.where(username: session[:username]).take
    tile = Board.find(params[:tile_id])
    tile.mark_as_bombed

    if !tile.ship_exists?
      game = tile.game
      game.switch_to_next_players_turn
    end

    redirect_to game_index_path(game_id: tile.game_id)
  end

end
