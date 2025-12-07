class AuctionsController < ApplicationController
  before_action :get_data

  def index
    @room = Room.find_by(user_id: session[:user]["id"])
  end

  
  def players
  end

  def create_room
    @rooms = Room.all 
    if @rooms.present?
      redirect_to auctions_path, alert: "An auction room already exists."
      return
    end

    @room = Room.new(user_id: session[:user]["id"])
    p @room
    if @room.save
      redirect_to room_path(@room.id), notice: "Auction room created successfully!"
    else
      redirect_to auctions_path, alert: "Failed to create auction room."
    end 
  end


end
