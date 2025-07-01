json.merge! @tour
json.matches @matches do |match|
  winner = @players.find{|p| p["id"].to_s == match["winner_captain_id"].to_s}
  loser_captain_id = (match["captain_a"].to_s == match["winner_captain_id"].to_s) ? match["captain_b"] : match["captain_a"]
  loser = @players.find{|p| p["id"].to_s == loser_captain_id.to_s}

  json.merge! match
  json.winner winner || nil
  json.loser loser || nil
end