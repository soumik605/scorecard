class StatsController < ApplicationController
  before_action :get_data

  def index
    @stats = []
    @stats << ["Most run", Player.most_runs(@performances, @players)]
    @stats << ["Most wicket", Player.most_wickets(@performances, @players)]
    @stats << ["Most duck", Player.most_ducks(@performances, @players)]
    @stats << ["Most 50", Player.most_fifties(@performances, @players)]
    @stats << ["Most 100", Player.most_hundreds(@performances, @players)]
    @stats << ["Most matches as captain", Player.captain_most_matches(@matches, @teams, @players)]
    @stats << ["Best win % (captain)", Player.captain_win_percentage(@matches, @teams, @players, "best")]
    @stats << ["Worst win % (captain)", Player.captain_win_percentage(@matches, @teams, @players, "worst")]
    @stats << ["Most win (captain)", Player.most_wins(@matches, @teams, @players)]
    @stats << ["Best batting innings", Performance.best_batting_innings(@performances, @players)]
    @stats << ["Best bowling innings", Performance.best_bowling_innings(@performances, @players)]
    @stats << ["Most win by innings", Match.most_wins_by_innings(@matches, @players)]
    @stats << ["Most win by follow on", Match.most_wins_by_follow_on(@matches, @players)]
  end

end
