class StatsController < ApplicationController

  def index
    @stats = []
    @stats << ["Most run", Player.most_runs]
    @stats << ["Most wicket", Player.most_wickets]
    @stats << ["Most duck", Player.most_ducks]
    @stats << ["Most 50", Player.most_fifties]
    @stats << ["Most 100", Player.most_hundreds]
    # @stats << ["Best win % (captain)", Player.captain_win_percentage(order: :desc)]
    # @stats << ["Worst win % (captain)", Player.captain_win_percentage(order: :asc)]
    @stats << ["Most win (captain)", Player.most_wins]
    # @stats << ["Most series win (captain)", Player.most_series_wins]
    @stats << ["Best batting innings", Performance.best_batting_innings]
    @stats << ["Best bowling innings", Performance.best_bowling_innings]
    # @stats << ["Most win by innings", Match.most_wins_by_innings]
    # @stats << ["Most win by follow on", Match.most_wins_by_follow_on]
  end

end
