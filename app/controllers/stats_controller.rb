class StatsController < ApplicationController
  before_action :get_data

  def index
    @captain_stats = []
    @player_stats = []

    @player_stats << ["Most run", Player.most_runs(@performances, @players)]
    @player_stats << ["Most wicket", Player.most_wickets(@performances, @players)]
    @player_stats << ["Most duck", Player.most_ducks(@performances, @players)]
    @player_stats << ["Most 50", Player.most_fifties(@performances, @players)]
    @player_stats << ["Most 100", Player.most_hundreds(@performances, @players)]
    @player_stats << ["Best batting innings", Performance.best_batting_innings(@performances, @players)]
    @player_stats << ["Best bowling innings", Performance.best_bowling_innings(@performances, @players)]
    @player_stats << ["Most run as player", Player.most_run_as_player(@performances, @matches, @players, false)]
    @player_stats << ["Most wicket as player", Player.most_wicket_as_player(@performances, @matches, @players, false)]
    
    @captain_stats << ["Most matches as captain", Player.captain_most_matches(@matches, @teams, @players)]
    @captain_stats << ["Best win %", Player.captain_win_percentage(@matches, @teams, @players, "best")]
    @captain_stats << ["Worst win %", Player.captain_win_percentage(@matches, @teams, @players, "worst")]
    @captain_stats << ["Most win", Player.most_wins(@matches, @teams, @players)]
    @captain_stats << ["Most win by innings", Match.most_wins_by_innings(@matches, @players)]
    @captain_stats << ["Most win by follow on", Match.most_wins_by_follow_on(@matches, @players)]
    @captain_stats << ["Most run as captain", Player.most_run_as_player(@performances, @matches, @players, true)]
    @captain_stats << ["Most wicket as captain", Player.most_wicket_as_player(@performances, @matches, @players, true)]
  end

end
