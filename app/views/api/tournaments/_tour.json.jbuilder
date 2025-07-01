@final = @matches.find{|m| (m["tournament_id"] == tour["id"]) && (m["match_type"] == "final")}

json.merge! tour
json.winner do
  if @final.present? && @final["winner_captain_id"].present?
    winner = @players.find{|p| p["id"].to_s == @final["winner_captain_id"].to_s}
    json.merge! winner || nil
  else 
    json.merge! nil
  end
end