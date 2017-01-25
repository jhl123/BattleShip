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
    @available_games = Game.where(user_2_id: nil).includes(:user_1).order(id: :desc)
  end
end
