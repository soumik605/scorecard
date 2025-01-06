class PlayersController < ApplicationController
  before_action :get_data
  before_action :set_player, only: [:update]

  def index 
  end

  def show
    @player = @players.find{|p| p["id"].to_s == params[:id].to_s}

    player_performances = @performances.filter{|perf| perf["player_id"].to_s == params[:id].to_s}

    @run_counts = player_performances.each_with_object(Hash.new(0)) do |player, counts|
      if player["runs"].present?
        counts[player["runs"]] += 1
      end
    end

    @total_run = player_performances.pluck("runs").reject { |record| record.nil? }.sum
    @total_wicket = player_performances.pluck("wickets").reject { |record| record.nil? }.sum

    @wicket_counts = player_performances.each_with_object(Hash.new(0)) do |player, counts|
      if player["wickets"].present?
        counts[player["wickets"]] += 1
      end
    end
    
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
