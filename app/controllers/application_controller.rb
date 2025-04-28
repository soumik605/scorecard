class ApplicationController < ActionController::Base
  require "json"

  def get_data
    matches_file = File.open "public/stats/matches.json"
    @matches = JSON.load matches_file

    players_file = File.open "public/stats/players.json"
    @players = JSON.load players_file

    tours_file = File.open "public/stats/tours.json"
    @tours = JSON.load tours_file

    performances_file = File.open "public/stats/performances.json"
    @performances = JSON.load performances_file

    super_file = File.open "public/stats/super.json"
    @super = JSON.load super_file
  end


end
