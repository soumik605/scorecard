class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user] = @user
      redirect_to root_path, notice: "Registered successfully!"
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password)
  end
end
