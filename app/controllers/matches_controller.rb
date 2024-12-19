class MatchesController < ApplicationController
  before_action :get_data
  before_action :set_match, only: [:show, :update]

  def show
  end

  def update
    if @match.update(match_params)
      respond_to do |format|
        format.turbo_stream { redirect_to request.referrer, notice: 'Done !!'}
      end
    else
    end
  end

  private

  def set_match
    @match = @matches.find{|m| m["id"].to_s == params[:id].to_s}
  end

  def match_params
    params.require(:match).permit(:winner_team_id, :date, :is_won_by_innings, :is_won_by_follow_on, :is_draw)
  end
  
end
