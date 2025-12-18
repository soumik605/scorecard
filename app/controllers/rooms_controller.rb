class RoomsController < ApplicationController
  before_action :get_data

  def show
    set_page_data
  end

  def my
    set_page_data
  end

  def join
    @room = Room.find_by(code: params[:code])
    @user = User.find_by(id: session[:user]["id"])
    
    return redirect_to auctions_path, alert: "Invalid room code." if @room.nil?
    
    room_users = User.where(room_id: @room.id)
    return redirect_to auctions_path, alert: "Room is full." if room_users.count >= 8

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
        picked_player.update(user_id: session[:user]["id"], last_pick_datetime: Time.now, team_type: nil)
        redirect_to request.referrer, notice: "Player picked successfully!"
      else 
        redirect_to request.referrer, alert: "Player already picked by other."
      end
    else
      redirect_to request.referrer, alert: "Error picking player."
    end

  end

  def release 
    if params[:picked_player_id].present?
      picked_player = PickedPlayer.find_by(id: params[:picked_player_id], user_id: session[:user]["id"])
      if picked_player.present? && picked_player.update(user_id: nil, last_pick_datetime: nil, team_type: nil)
        redirect_to request.referrer, notice: "Player released successfully!"
      else 
        redirect_to request.referrer, alert: picked_player.errors.full_messages.to_sentence
      end
    else
      redirect_to request.referrer, alert: "Error picking player."
    end

  end

  def players
    @room = Room.find_by(id: params[:id])
    @users = User.all.where(room_id: params[:id])
    p @users
    @players = PickedPlayer.where(room_id: params[:id]).where.not(user_id: nil).order("last_pick_datetime DESC")
  end

  def update_team_type
    @my_picked_players = PickedPlayer.where(user_id: session[:user]["id"])

    player = @my_picked_players.find_by(id: params[:id])
    team_type = params[:team_type]

    if team_type.present? && @my_picked_players.where(team_type: team_type).count >= 11
      redirect_to request.referrer, alert: "Max 11 players allowed."
      return
    end

    player.update!(team_type: team_type.presence)
    redirect_to request.referrer, notice: "Player moved to #{team_type} team"
  end



  private 

  def set_page_data
    @room = Room.find(params[:id])
    @auction_players_by_id = @auction_players.index_by { |p| p["id"] }

    @available_to_pick_players = PickedPlayer
                                  .where(user_id: nil)
                                  .where("release_time <= ?", Time.current)
                                  .order(:release_time) # base ordering
                                  .group_by do |picked_player|
                                    auction_player = @auction_players_by_id[picked_player.player_id]
                                    auction_player&.dig("country_code")
                                  end
                                  .transform_values do |players|
                                    players.sort_by do |p|
                                      p.release_time.in_time_zone("Asia/Kolkata")
                                    end
                                  end

    @my_picked_players = PickedPlayer.where(user_id: session[:user]["id"])

    @country_wise_picked_players = @my_picked_players
                            .order(:last_pick_datetime)
                            .group_by do |picked_player|
                              auction_player = @auction_players_by_id[picked_player.player_id]
                              auction_player&.dig("country_code") || "UNKNOWN"
                            end

    my_picked_player_ids = @my_picked_players.pluck(:player_id)

    @total_spent_price = @auction_players.map{|pp| my_picked_player_ids.include?(pp["id"]) ? pp["price"] : 0 }.sum
    @total_available_price = 1550 - @total_spent_price
    @can_take_action = Time.current.between?(@room.start_date, @room.end_date)
  end

end
