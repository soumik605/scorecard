module PlayersHelper

  def getPlayerRunData player
    innings = Performance.where(id: player.performances.where.not(runs: nil).pluck(:id)).distinct
    matches = Match.where(id: innings.pluck(:match_id)).distinct
    obj = innings.pluck(:runs, :is_not_out).compact.select { |x| x[0].is_a?(Numeric)}
    total_run = obj.map(&:first).sum
    not_out = innings.where(is_not_out: true).count
    out = innings.where(is_not_out: false).count
    average = out > 0 ? total_run/out : nil
    zero_count = innings.where(runs: 0).count
    range_1_count = innings.where("runs between 1 and 30").count
    range_2_count = innings.where("runs between 31 and 49").count
    range_3_count = innings.where("runs between 50 and 99").count
    range_4_count = innings.where("runs > 99").count

    return [total_run, average, matches.count, innings.count, not_out, zero_count, range_1_count, range_2_count, range_3_count, range_4_count]
  end



  def getPlayerWicketData player
    innings = Performance.where(id: player.performances.where.not(wickets: nil).pluck(:id))
    matches = Match.where(id: innings.pluck(:match_id)).distinct
    all_wickets = innings.pluck(:wickets).compact.select { |x| x.is_a?(Numeric) }
    total_wickets = all_wickets.sum
    zero_count = all_wickets.count(0)
    range_1_count = all_wickets.count(3)
    range_2_count = all_wickets.count(4)
    range_3_count = all_wickets.count { |num| num > 4 }

    return [total_wickets, matches.count, innings.count, range_1_count, range_2_count, range_3_count, zero_count]
  end


end
