class GameController < ApplicationController
  include ApplicationHelper

  def index
    @user = User.where(username: session[:username]).take
    @hit = params[:hit] == "true"
    @sunk = params[:sunk] == "true"
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

      # Defined in ApplicationHelper
      board_cache = get_cache(@game.id)

      @player_board = board_cache[@game.id][@user.id]
      opponent_id = @game.user_1_id != @user.id ? @game.user_1_id : @game.user_2_id
      @opponent_user = User.find(opponent_id)
      @opponent_board = board_cache[@game.id][opponent_id]
      @total_ships = Ship.count
    end
  end

  def fire_missile
    @user = User.where(username: session[:username]).take
    tile = Board.find(params[:tile_id])
    tile.mark_as_bombed
    game = tile.game

    hit = tile.ship_exists?
    sunk = tile.ship_sunk?
    
    if hit
      # Defined in ApplicationHelper
      if sunk && is_game_complete?(tile)  
        game.update_winner(@user)
      end
    else
      game.switch_to_next_players_turn
    end

    redirect_to game_index_path(game_id: tile.game_id, hit: hit, sunk: sunk)
  end

end
