class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  def show
  end

  private

  def set_match
    @match = Match.find_by(id: params[:id])
  end
  
end
