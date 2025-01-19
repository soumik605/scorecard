json.status "success"
json.message ""
json.data do
  json.player_stats @player_stats
  json.captain_stats @captain_stats
  json.performances @performances
  json.run_counts @run_counts.sort.to_h
end
