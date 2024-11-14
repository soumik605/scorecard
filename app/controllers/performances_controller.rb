class PerformancesController < ApplicationController
  before_action :set_performance, only: [:update]

  def create
    @performance = Performance.new(performance_params)
    respond_to do |format|
      if @performance.save
        format.turbo_stream { redirect_to match_path(@performance.match), notice: 'Done !!'}
      else
        p @performance.errors
        format.turbo_stream { redirect_to request.referrer, notice: @performance.errors.full_messages}
      end
    end
  end


  def update
    respond_to do |format|
      if @performance.update(performance_params)
        format.turbo_stream { redirect_to match_path(@performance.match), notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @performance.errors.full_messages}
      end
    end
  end 

  private 

  def performance_params
    params.require(:performance).permit(:runs, :wickets, :player_id, :match_id)
  end

  def set_performance
    @performance = Performance.find(params[:id])
  end

end
