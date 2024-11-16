class RankingsController < ApplicationController
  def index
    @players = Player.all

    @runs = []
    @players.each do |p|
      latest_perf = Performance.where(id: p.performances.where.not(runs: nil).last(10).pluck(:id))
      out = latest_perf.where(is_not_out: false).count
      not_out = latest_perf.count - latest_perf.where(is_not_out: false).count
      total = latest_perf.pluck(:runs).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
      point = total * (1 + (not_out.to_f / latest_perf.count.to_f))
      @runs << [p.name, total, out>0 ? total/out : "-", point]
    end
    @runs = @runs.sort_by { |name, score, average, point| [-point, score, average, name] }


    @wickets = []
    @players.each do |p|
      innings = p.performances.where.not(wickets: nil).last(10)
      total_wickets = innings.pluck(:wickets).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
      point = (total_wickets.to_f / innings.count.to_f) * 100
      @wickets << [p.name, point, total_wickets]
    end
    @wickets = @wickets.sort_by { |name, point, wicket| [-point, wicket, name] }


  end
end
