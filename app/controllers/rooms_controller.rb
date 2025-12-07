class RoomsController < ApplicationController
  before_action :get_data

  def show
    @room = Room.find(params[:id])
    @available_to_pick_players = PickedPlayer.where(user_id: nil)
    @my_picked_players = PickedPlayer.where(user_id: session[:user]["id"])
  end

  def join
    @room = Room.find_by(code: params[:code])
    @user = User.find_by(id: session[:user]["id"])
    if @room.present? && @user.present? && @user.update(room_id: @room.id)
      redirect_to room_path(@room.id), notice: "Joined room successfully!"
    else
      redirect_to auctions_path, alert: "Invalid room code."
    end
  end

  def pick 
    if params[:picked_player_id].present?
      picked_player = PickedPlayer.find_by(id: params[:picked_player_id], user_id: nil)
      if picked_player.present?
        picked_player.update(user_id: session[:user]["id"])
        redirect_to request.referrer, notice: "Player picked successfully!"
      else 
        redirect_to request.referrer, alert: "Player already picked by other."
      end
    else
      redirect_to request.referrer, alert: "Error picking player."
    end

  end

end
