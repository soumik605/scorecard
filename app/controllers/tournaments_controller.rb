class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update]
  def index
    @tours = Tournament.all
  end

  def show
    @matches = @tour.matches
  end

  def create
  end

  def edit
  end

  def update

  end

  private 

  def set_tournament
    @tour = Tournament.find(params[:id])
  end

end
