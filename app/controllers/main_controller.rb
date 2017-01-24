class MainController < ApplicationController
  def index
    session[:username] = params["username"].nil? ? "guest" : params["username"]
    @user = User.where(username: session[:username]).take
    if @user.nil?
      @user = User.create(username: session[:username])
    end
    @available_games = Game.where(user_2_id: nil).includes(:user_1).order(id: :desc)
  end
end
