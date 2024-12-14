class StatsController < ApplicationController

  def index
    @stats = []
    @stats << ["Most run", Player.joins(:performances).select('players.*, SUM(performances.runs) AS total_runs').group('players.id').order('total_runs DESC').first.name]
    @stats << ["Most wicket", Player.joins(:performances).select('players.*, SUM(performances.wickets) AS total_wickets').group('players.id').order('total_wickets DESC').first.name]
    @stats << ["Most duck", Player.joins(:performances).select('players.*, COUNT(performances.id) AS duck_count').where(performances: { runs: 0 }).group('players.id').order('duck_count DESC').first.name]
    @stats << ["Most 50", Player.joins(:performances).select('players.*, COUNT(performances.id) AS fifty_count').where('performances.runs >= 50 AND performances.runs < 100').group('players.id').order('fifty_count DESC').first]
    @stats << ["Most 100", Player.joins(:performances).select('players.*, COUNT(performances.id) AS hundred_count').where('performances.runs >= 100').group('players.id').order('hundred_count DESC').first.name]
    @stats << ["Best win % (captain)", ""]
    @stats << ["Worst win % (captain)", ""]
    @stats << ["Most win (captain)", ""]
    @stats << ["Most series win (captain)", ""]
    @stats << ["Best batting innings", Performance.with_runs.joins(:player).select('performances.*, players.name AS player_name').order('runs DESC').first.runs]
    @stats << ["Best bowling innings", Performance.with_wickets.joins(:player).select('performances.*, players.name AS player_name').order('wickets DESC').first.wickets]
    @stats << ["Most win by innings", ""]
    @stats << ["Most win by follow on", ""]
  end

end
