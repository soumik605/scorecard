@matches = @matches.filter{|m| m["tournament_id"] == tour["id"]}
@final = @matches.present? ? @matches.find{|m| m["match_type"] == "final"} : {}

json.tour do 
  json.tour_details tour
  json.winner @players.find{|p| p["id"].to_s == @final["winner_captain_id"].to_s}
end
