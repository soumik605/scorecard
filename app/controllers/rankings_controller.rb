class RankingsController < ApplicationController
  def index
    @players = Player.all

    @runs = []
    @players.each do |p|
      latest_perf = Performance.where(id: p.performances.last(10).pluck(:id))
      out = latest_perf.where(is_not_out: false).count
      total = latest_perf.pluck(:runs).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
      @runs << [p.name, total, out>0 ? total/out : "-"]
    end
    @runs = @runs.sort_by { |name, score| [-score, name] }


    @wickets = []
    @players.each do |p|
      @wickets << [p.name, p.performances.last(10).pluck(:wickets).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end
    @wickets = @wickets.sort_by { |name, score| [-score, name] }


  end
end
