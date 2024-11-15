class RankingsController < ApplicationController
  def index
    @players = Player.all

    @runs = []
    @players.each do |p|
      @runs << [p.name, p.performances.last(10).pluck(:runs).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end
    @runs = @runs.sort_by { |name, score| [-score, name] }


    @wickets = []
    @players.each do |p|
      @wickets << [p.name, p.performances.last(10).pluck(:wickets).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end
    @wickets = @wickets.sort_by { |name, score| [-score, name] }


  end
end
