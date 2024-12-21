module PlayersHelper

  def getPlayerRunData player, performances, matches
    innings = performances.filter{|p| (p["player_id"] == player["id"]) && p["runs"].present? }
    matches = matches.filter{ |m| innings.pluck("match_id").include?(m["id"])}.uniq
    obj = innings.pluck("runs", "is_not_out").compact.select { |x| x[0].is_a?(Numeric)}
    p obj
    total_run = obj.map(&:first).sum
    not_out = innings.filter{ |i| i["is_not_out"] == true}.count
    out = innings.filter{ |i| i["is_not_out"] == false}.count
    average = out > 0 ? total_run/out : nil
    zero_count = innings.filter{ |i| i["runs"] == 0}.count
    range_1_count = innings.filter{ |i| i["runs"] >= 1 && i["runs"] <= 30}.count
    range_2_count = innings.filter{ |i| i["runs"] >= 31 && i["runs"] <= 49}.count
    range_3_count = innings.filter{ |i| i["runs"] >= 50 && i["runs"] <= 99}.count
    range_4_count = innings.filter{ |i| i["runs"] >= 100}.count
    max_value, is_not_out = nil, nil
    
    max_value, is_not_out = obj.max_by { |num, bool| [num, bool ? 1 : 0] } if obj.present? 

    highest = ""
    if max_value.present?
      highest = is_not_out ? "#{max_value}*" : max_value
    end

    return [total_run, innings.count, average, matches.count, highest, not_out, zero_count, range_1_count, range_2_count, range_3_count, range_4_count]
  end



  def getPlayerWicketData player, performances, matches
    innings = performances.filter{|p| (p["player_id"] == player["id"]) && p["wickets"].present? }
    matches = matches.filter{ |m| innings.pluck("match_id").include?(m["id"])}.uniq
    all_wickets = innings.pluck("wickets").compact.select { |x| x.is_a?(Numeric) }
    total_wickets = all_wickets.sum
    zero_count = all_wickets.count(0)
    range_1_count = all_wickets.count(3)
    range_2_count = all_wickets.count(4)
    range_3_count = all_wickets.count { |num| num > 4 }

    return [total_wickets, matches.count, innings.count, range_1_count, range_2_count, range_3_count, zero_count]
  end


end
