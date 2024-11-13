class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard]
  def index
    @tours = Tournament.all
  end

  def show
  end

  def new
    @tournament = Tournament.new
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
  end

  def leaderboard
    @players = Player.all
    @players_data = []

    @players.each do |player|
      @players_data << [player.name, Team.where(match_id: @matches.pluck(:id), captain_id: player.id).pluck(:total_point).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end

    @players_data = @players_data.sort_by { |name, score| [-score, name] }

  end

  private 

  def set_tournament
    @tour = Tournament.find(params[:id])
    @matches = @tour.matches
  end

  def tournament_params
    params.require(:tournament).permit(:name, :win_point, :draw_point, :innings_win_point, :follow_on_win_point)
  end

end
