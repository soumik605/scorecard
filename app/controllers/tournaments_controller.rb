class TournamentsController < ApplicationController
  before_action :get_data
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard]


  def index
    @tours = @tours.filter{|t| t["is_removed"].to_s == "false"}
  end

  def show
  end

  def new
    @tournament = Tournament.new
    @players = Player.all
  end

  def create
    @tour = Tournament.new(tournament_params)
    respond_to do |format|
      if @tour.save
        format.turbo_stream { redirect_to tournament_path(@tour), notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @tour.errors.full_messages}
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @tour.update(tournament_params)
        format.turbo_stream { redirect_to tournament_path(@tour), notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @tour.errors.full_messages}
      end
    end
  end

  def leaderboard    
    @teams = @teams.filter{|t| @matches.pluck("id").include?t["match_id"]}
    @players = @players.filter { |p| @teams.pluck("captain_id").include?(p["id"])}
    
    @players_data = []

    @players.each do |player|
      teams = @teams.filter{|t| @matches.pluck("id").include?(t["match_id"]) && (t["captain_id"] == player["id"])}
      matches = @matches.filter{|m| teams.pluck("match_id").include?m["id"]}
      @players_data << [player["name"], matches.filter{|m| m["winner_team_id"].present? }.uniq.count, matches.filter{|m| m["winner_team_id"] == nil }.uniq.count, teams.pluck("total_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end

    @players_data = @players_data.sort_by { |name, complete, pending, score| [-score, complete, -pending, name] }

  end

  private 

  def set_tournament
    @tour = @tours.find{ |t| t["id"].to_s == params[:id].to_s}
    @matches = @matches.filter{|m| m["tournament_id"].to_s == params[:id].to_s}
  end

  def tournament_params
    params.require(:tournament).permit(:name, :is_removed, :win_point, :draw_point, :innings_win_point, :follow_on_win_point, :round_count, captain_ids: [])
  end

end
