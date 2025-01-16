class Api::PlayersController < ApplicationController
  before_action :get_data

  def index
    respond_to do |format|
      format.json { render json: { status: 'success' , message: "", players: @players }, status: :ok }
    end
  end

  def show
    @player = @players.find{|p| p["id"].to_s == params[:id].to_s}
    respond_to do |format|
      format.json { render json: { status: 'success' , message: "", player: @player }, status: :ok }
    end
  end

end
