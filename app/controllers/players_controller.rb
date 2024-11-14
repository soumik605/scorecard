class PlayersController < ApplicationController

  before_action :set_player, only: [:update]

  def index 
    @players = Player.all.order("created_at ASC")
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    respond_to do |format|
      if @player.save
        format.turbo_stream { redirect_to players_path, notice: 'Done !!'}
      else
        p @player.errors
        format.turbo_stream { redirect_to request.referrer, notice: @player.errors.full_messages}
      end
    end
  end


  def update
    respond_to do |format|
      if @player.update(player_params)
        format.turbo_stream { redirect_to players_path, notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @player.errors.full_messages}
      end
    end
  end 

  private 

  def player_params
    params.require(:player).permit(:name)
  end

  def set_player
    @player = Player.find(params[:id])
  end

end
