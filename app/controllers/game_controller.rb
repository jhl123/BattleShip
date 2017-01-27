class GameController < ApplicationController
  include ApplicationHelper

  def index
    @user = User.where(username: session[:username]).take
    if !params[:hit].nil?
      @hit = params[:hit] == "true"
    end
    
    if !params[:sunk].nil?
      @sunk = params[:sunk] == "true"
    end


    
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
      game_cache = ApplicationController.helpers.get_cache(@game.id)

      @player_board = game_cache[@user.id]
      @opponent_user = @game.get_opponent(@user.id)
      @opponent_board = game_cache[@opponent_user.id]
      @total_ships = Ship.count
      @last_move = Hash.new
      @last_move[@user.id] = ApplicationController.helpers.get_last_move(@game.id, @user.id)
      @last_move[@opponent_user.id] = ApplicationController.helpers.get_last_move(@game.id, @opponent_user.id)
    end
  end

  def fire_missile
    @user = User.where(username: session[:username]).take
    tile = Board.find(params[:tile_id])
    game = tile.game
    
    if game.next_turn_user_id != @user.id
      redirect_to game_index_path(game_id: tile.game_id)
      return
    end

    tile.mark_as_bombed
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

    ApplicationController.helpers.add_last_move_to_cache(@user.id, tile)
    redirect_to game_index_path(game_id: tile.game_id, hit: hit, sunk: sunk)
  end

end
