class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:view, :edit, :update]
  def index
    @tours = Tournament.all
  end

  def view
  end

  def create
  end

  def edit
  end

  def update

  end

  private 

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

end
