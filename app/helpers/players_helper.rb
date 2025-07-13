module PlayersHelper

  def getPlayerRunData player, performances, matches, tour_type, tournament
    tour_ids = tournament.filter{|t| t["tour_type"] == tour_type}.pluck("id")
    matches = matches.filter{ |m| tour_ids.include?(m["tournament_id"]) }

    match_ids = matches.pluck("id")
    player_match_ids = matches.filter{|m| [m["captain_a"], m["captain_b"]].include? player["id"]}
    
    performances = performances.filter{|p| p["player_id"] == player["id"] && p["runs"].present? && match_ids.include?(p["match_id"]) }

    obj = performances.pluck("runs", "is_not_out").compact.select { |x| x[0].is_a?(Numeric)}
    total_run = obj.map(&:first).sum
    not_out = performances.filter{ |i| i["is_not_out"] == true}.count
    out = performances.filter{ |i| i["is_not_out"] == false}.count
    average = out > 0 ? (total_run.try(:to_f)/out).try(:round) : nil
    run_per_innings = performances.count == 0 ? "" : (total_run.try(:to_f)/(performances.count)).try(:round)
    zero_count = performances.filter{ |i| i["runs"] == 0}.count
    range_1_count = performances.filter{ |i| i["runs"] >= 1 && i["runs"] <= 30}.count
    range_2_count = performances.filter{ |i| i["runs"] >= 31 && i["runs"] <= 49}.count
    range_3_count = performances.filter{ |i| i["runs"] >= 50 && i["runs"] <= 99}.count
    range_4_count = performances.filter{ |i| i["runs"] >= 100}.count
    max_value, is_not_out = nil, nil
    
    max_value, is_not_out = obj.max_by { |num, bool| [num, bool ? 1 : 0] } if obj.present? 

    highest = ""
    if max_value.present?
      highest = is_not_out ? "#{max_value}*" : max_value
    end

    return [total_run, performances.count, average, run_per_innings, player_match_ids.count, highest, not_out, zero_count, range_1_count, range_2_count, range_3_count, range_4_count]
  end



  def getPlayerWicketData player, performances, matches, tour_type, tournament
    tour_ids = tournament.filter{|t| t["tour_type"] == tour_type}.pluck("id")
    matches = matches.filter{ |m| tour_ids.include?(m["tournament_id"]) }

    match_ids = matches.pluck("id")
    player_match_ids = matches.filter{|m| [m["captain_a"], m["captain_b"]].include? player["id"]}
    
    performances = performances.filter{|p| p["player_id"] == player["id"] && p["runs"].present? && match_ids.include?(p["match_id"]) }

    all_wickets = performances.pluck("wickets").compact.select { |x| x.is_a?(Numeric) }
    total_wickets = all_wickets.sum
    zero_count = all_wickets.count(0)
    range_1_count = all_wickets.count(3)
    range_2_count = all_wickets.count(4)
    range_3_count = all_wickets.count { |num| num > 4 }

    return [total_wickets, player_match_ids.count, performances.count, range_1_count, range_2_count, range_3_count, zero_count]
  end



  def getPlayerPointData player_id, points
    matches = points.values.flatten
    player_points = matches.pluck("#{player_id}")
    player_points = player_points.reject { |record| record.nil? }
    
    innings_count = player_points.count
    total_points = player_points.sum
    average = (total_points.to_f / innings_count).round(2)
    highest = player_points.max
    zero_count = player_points.count { |num| num <= 0 }
    range_1_count = player_points.count { |num| num >= 1 && num <= 30 }
    range_2_count = player_points.count { |num| num >= 31 && num <= 49 }
    range_3_count = player_points.count { |num| num >= 50 && num <= 99 }
    range_4_count = player_points.count { |num| num >= 100 }

    return [total_points, innings_count, average, highest, zero_count, range_1_count, range_2_count, range_3_count, range_4_count]
  end


  def getPlayerName id, players
    players.find{|p| p["id"] == id }["name"]
  end

  def getPlayerPhoto id, players
    players.find{|p| p["id"] == id }["photo_name"]
  end

  def getH2HClass wins, looses

    if wins == looses
      return "bg-gradient-to-r from-blue-100 to-blue-300"
    elsif wins > looses
      return "bg-gradient-to-r from-green-100 to-green-300"
    else
      return "bg-gradient-to-r from-red-100 to-red-300"
    end

  end


end
