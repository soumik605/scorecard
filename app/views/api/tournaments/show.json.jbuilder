json.merge! @tour

if @tour["tour_type"] == "super_over"
  json.matches @super do |match|
    json.winners match[0] do |winner|
      json.merge! @players.find{|p| p["id"].to_s == winner.to_s}
    end
    json.losers match[1] do |loser|
      json.merge! @players.find{|p| p["id"].to_s == loser.to_s}
    end
  end
elsif @tour["tour_type"] == "solo_test"
  json.matches @points.reverse do |match|
    json.array! match.each do |m|
      plr = @players.find{|p| p["id"].to_s == m[0].to_s}
      if plr
        plr["point"] = m[1]
        json.set! :id, plr["id"]
        json.set! :name, plr["name"]
        json.set! :point, plr["point"]
      end
    end
  end
else
  json.matches @matches do |match|
    winner = @players.find{|p| p["id"].to_s == match["winner_captain_id"].to_s}
    loser_captain_id = (match["captain_a"].to_s == match["winner_captain_id"].to_s) ? match["captain_b"] : match["captain_a"]
    loser = @players.find{|p| p["id"].to_s == loser_captain_id.to_s}
  
    json.merge! match
    json.winner winner || nil
    json.loser loser || nil
  end
end
