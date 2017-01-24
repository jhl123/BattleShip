class GameController < ApplicationController
  def index

    @user = User.where(username: session[:username]).take
    if !params[:game_id].nil?
      @game = Game.find(params[:game_id])
      if !@game.has_started && @user.id != @game.user_1_id
        @game.add_user(@user.id)
        @game.begin
        Board.create_new_boards(@game)
      end
    else
      @game = Game.create(user_1_id: @user.id)
    end

  end


end
