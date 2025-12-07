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

    points_file = File.open "public/stats/points.json"
    @points = JSON.load points_file

    test15_file = File.open "public/stats/test15.json"
    @test15 = JSON.load test15_file

    auction_players = File.open "public/auction/players.json"
    @auction_players = JSON.load auction_players
  end


end
