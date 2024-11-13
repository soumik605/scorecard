class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard]
  def index
    @tours = Tournament.all
  end

  def show
  end

  def create
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

end
