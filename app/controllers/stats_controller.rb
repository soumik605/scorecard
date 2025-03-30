class StatsController < ApplicationController
  before_action :get_data

  def test 
    set_data("test")
  end


  def t10
    set_data("t10")
  end

  def set_data tour_type
    @tours = @tours.filter{|t| tour_type == t["tour_type"]}
    @matches = @matches.filter{|m| @tours.pluck("id").include?(m["tournament_id"])}
    @performances = @performances.filter{|p| @matches.pluck("id").include?(p["match_id"])}
    
    @playoff_matches = @matches.filter{|m| ( @tours.pluck("id").include?(m["tournament_id"]) && ["q1", "q2", "final"].include?(m["match_type"]) )}
    @playoff_performances = @performances.filter{|p| @playoff_matches.pluck("id").include?(p["match_id"])}

    @captain_stats = []
    @player_stats = []

    @player_stats << ["Most average", Player.most_average_as_player(@performances, @matches, @players, false)]
    @player_stats << ["Most run", Player.most_runs(@performances, @players)]
    @player_stats << ["Most wicket", Player.most_wickets(@performances, @players)]
    @player_stats << ["Most run in knock-out", Player.most_runs(@playoff_performances, @players)]
    @player_stats << ["Most wicket in knock-out", Player.most_wickets(@playoff_performances, @players)]
    @player_stats << ["Most duck", Player.most_ducks(@performances, @players)]
    @player_stats << ["Most 50", Player.most_fifties(@performances, @players)]
    @player_stats << ["Most 100", Player.most_hundreds(@performances, @players)]
    @player_stats << ["Best batting innings", Performance.best_batting_innings(@performances, @players)]
    @player_stats << ["Best bowling innings", Performance.best_bowling_innings(@performances, @players)]
    @player_stats << ["Best batting innings in knock-out", Performance.best_batting_innings(@playoff_performances, @players)]
    @player_stats << ["Best bowling innings in knock-out", Performance.best_bowling_innings(@playoff_performances, @players)]
    @player_stats << ["Most run as player", Player.most_run_as_player(@performances, @matches, @players, false)]
    @player_stats << ["Most wicket as player", Player.most_wicket_as_player(@performances, @matches, @players, false)]
    @player_stats << ["Most consicutive innings without duck", Player.most_consicutive_innings_without_duck(@performances, @players)]
    
    @captain_stats << ["Most average", Player.most_average_as_player(@performances, @matches, @players, true)]
    @captain_stats << ["Most matches as captain", Player.captain_most_matches(@matches, @teams, @players)]
    @captain_stats << ["Best win %", Player.captain_win_percentage(@matches, @teams, @players, "best")]
    @captain_stats << ["Worst win %", Player.captain_win_percentage(@matches, @teams, @players, "worst")]
    @captain_stats << ["Most win", Player.most_wins(@matches, @teams, @players)]
    @captain_stats << ["Most win by innings", Match.most_wins_by_innings(@matches, @players)] if tour_type == "test"
    @captain_stats << ["Most win by follow on", Match.most_wins_by_follow_on(@matches, @players)] if tour_type == "test"
    @captain_stats << ["Most run as captain", Player.most_run_as_player(@performances, @matches, @players, true)]
    @captain_stats << ["Most wicket as captain", Player.most_wicket_as_player(@performances, @matches, @players, true)]
    @captain_stats << ["Most run as captain in knock-out", Player.most_run_as_player(@playoff_performances, @matches, @players, true)]
    @captain_stats << ["Most wicket as captain in knock-out", Player.most_wicket_as_player(@playoff_performances, @matches, @players, true)]
    @captain_stats << ["Most consicutive win", Player.most_consicutive_win(@matches, @players)]
    @captain_stats << ["Best win % against a captain (min 5 match)", Match.best_win_percent_against_captain(@matches, @players)]

    @run_result = {}
    cumulative_runs = Hash.new(0)
    run_innings_count = Hash.new(0)

    @wicket_result = {}
    cumulative_wickets = Hash.new(0)
    wicket_innings_count = Hash.new(0)

    @performances.each do |entry|
      player_id = entry["player_id"]
      player = @players.find{|p| p["id"] == player_id}
      if entry["runs"].present? && [1,2,3,4,5].include?(player_id)
        run_innings_count[player["name"]] += 1 
        cumulative_runs[player["name"]] += entry["runs"].try(:to_i) || 0
        key = [player["name"], run_innings_count[player["name"]]]
        @run_result[key] = cumulative_runs[player["name"]]
      end

      if entry["wickets"].present? && [1,2,3,4,5].include?(player_id)
        wicket_innings_count[player["name"]] += 1 
        cumulative_wickets[player["name"]] += entry["wickets"].try(:to_i) || 0
        key = [player["name"], wicket_innings_count[player["name"]]]
        @wicket_result[key] = cumulative_wickets[player["name"]]
      end
    end

    @run_counts = @performances.each_with_object(Hash.new(0)) do |player, counts|
      if player["runs"].present? && player["runs"].to_i > 0
        counts[player["runs"]] += 1
      end
    end
  end


  def head_to_head
    @head_to_head = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = { wins: 0, losses: 0 } } }

    @matches.each do |match|
      captain_a = match["captain_a"]
      captain_b = match["captain_b"]
      winner = match["winner_captain_id"]
    
      if winner == captain_a
        @head_to_head[captain_a][captain_b][:wins] += 1
        @head_to_head[captain_b][captain_a][:losses] += 1
      elsif winner == captain_b
        @head_to_head[captain_b][captain_a][:wins] += 1
        @head_to_head[captain_a][captain_b][:losses] += 1
      end
    end
    
    puts "Head-to-head results:"
    @head_to_head.each do |captain_a, opponents|
      opponents.each do |captain_b, results|
        puts "Captain #{captain_a} vs Captain #{captain_b}: #{results[:wins]} wins, #{results[:losses]} losses"
      end
    end
  end



end
