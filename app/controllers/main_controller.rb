class MainController < ApplicationController
  def index

    if !params["username"].nil?
      session[:username] = params["username"]
    elsif session[:username].nil?
      session[:username] = "guest" 
    end

    @user = User.where(username: session[:username]).take
    if @user.nil?
      @user = User.create(username: session[:username])
    end

    @completed_games = Game.includes(:user_1)
                           .includes(:user_2)
                           .order(id: :desc)
                           .where.not(user_2_id: nil)
                           .where('user_1_id = ? OR user_2_id = ?', @user.id, @user.id)
                           .where.not(winner_id: nil)
    @user_unstarted_games = Game.where(user_1_id: @user.id, user_2_id: nil)
                                .includes(:user_1)
                                .order(id: :desc)
    @in_process_games = Game.includes(:user_1)
                           .includes(:user_2)
                           .order(id: :desc)
                           .where.not(user_2_id: nil)
                           .where('user_1_id = ? OR user_2_id = ?', @user.id, @user.id)
                           .where(winner_id: nil)
    @available_games = Game.where.not(user_1_id: @user.id)
                           .where(user_2_id: nil)
                           .includes(:user_1)
                           .order(id: :desc)
  end
end


# Game.includes(:user_1).includes(:user_2).order(id: :desc).where('user_1_id = ? OR user_2_id = ?', @user.id, @user.id).where(winner_id: nil)