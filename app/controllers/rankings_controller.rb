class RankingsController < ApplicationController
  before_action :get_data
  def test
    @test_tours = @tours.filter{|t| t['tour_type'] == 'test'}
    @test_matches = @matches.filter{|m| @test_tours.pluck("id").include?(m["tournament_id"])}
    @test_performances = @performances.filter{|p| @test_matches.pluck("id").include?(p["match_id"])}

    @batting_ranking = Player.batting_ranking(@test_performances, @players)
    @bowling_ranking = Player.bowling_ranking(@test_performances, @players)
  end


  def t10
    @t10_tours = @tours.filter{|t| t['tour_type'] == 't10'}
    @t10_matches = @matches.filter{|m| @t10_tours.pluck("id").include?(m["tournament_id"])}
    @t10_performances = @performances.filter{|p| @t10_matches.pluck("id").include?(p["match_id"])}

    @batting_ranking = Player.batting_ranking(@t10_performances, @players)
    @bowling_ranking = Player.bowling_ranking(@t10_performances, @players)
  end

end
