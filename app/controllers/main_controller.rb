class MainController < ApplicationController
  def index
    username = params["username"].nil? ? "guest" : params["username"]
    @user = User.where(username: username).take
    if @user.nil?
      @user = User.create(username: username)
    end
    session[:user] = @user
  end
end
