class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard]
  def index
    if user_signed_in?
      @tours = Tournament.all
    else
      @tours = Tournament.where(is_removed: false)
    end
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
    @players = Player.where(id: Team.where(match_id: @tour.matches.pluck(:id)).pluck(:captain_id))
    @players_data = []

    @players.each do |player|
      teams = Team.where(match_id: @matches.pluck(:id), captain_id: player.id)
      matches = Match.joins(:teams).where("teams.captain_id = ?", player.id ).where(tournament_id: @tour.id).distinct
      @players_data << [player.name, matches.where.not(winner_team_id: nil).uniq.count, matches.where(winner_team_id: nil).count, teams.pluck(:total_point).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end

    @players_data = @players_data.sort_by { |name, complete, pending, score| [-score, complete, -pending, name] }

  end

  private 

  def set_tournament
    @tour = Tournament.find(params[:id])
    @matches = @tour.matches.order("created_at desc")
  end

  def tournament_params
    params.require(:tournament).permit(:name, :is_removed, :win_point, :draw_point, :innings_win_point, :follow_on_win_point, :round_count, captain_ids: [])
  end

end
