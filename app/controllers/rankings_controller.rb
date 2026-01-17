class RankingsController < ApplicationController
  before_action :get_data
  def test
    @test_tours = @tours.filter{|t| t['tour_type'] == 'test'}
    @test_matches = @matches.filter{|m| @test_tours.pluck("id").include?(m["tournament_id"])}
    @test_performances = @performances.filter{|p| @test_matches.pluck("id").include?(p["match_id"])}

    @batting_ranking = Player.batting_ranking(@test_performances, @players)
    @highest_batting_ranking = Player.highest_batting_ranking(@test_performances, @players)

    @bowling_ranking = Player.bowling_ranking(@test_performances, @players)
    @highest_bowling_ranking = Player.highest_bowling_ranking(@test_performances, @players)

    @allround_ranking = Player.allround_ranking(@test_performances, @players)
    @highest_allround_ranking = Player.highest_allround_ranking(@test_performances, @players)
  end


  def t10
    @t10_tours = @tours.filter{|t| t['tour_type'] == 't10'}
    @t10_matches = @matches.filter{|m| @t10_tours.pluck("id").include?(m["tournament_id"])}
    @t10_performances = @performances.filter{|p| @t10_matches.pluck("id").include?(p["match_id"])}

    @batting_ranking = Player.batting_ranking(@t10_performances, @players)
    @highest_batting_ranking = Player.highest_batting_ranking(@t10_performances, @players)

    @bowling_ranking = Player.bowling_ranking(@t10_performances, @players)
    @highest_bowling_ranking = Player.highest_bowling_ranking(@t10_performances, @players)

    @allround_ranking = Player.allround_ranking(@t10_performances, @players)
    @highest_allround_ranking = Player.highest_allround_ranking(@t10_performances, @players)
  end

  def solo_test
    @result = {}

    result = {}

    (1..13).each do |key|
      string_key = key.to_s
      player = @players.find{|p| p["id"] == key}

      # Traverse from the end and collect last 10 values where the key is present
      values = @points["6"].reverse.map { |h| h[string_key] }.compact.first(10)

      weights = [5, 5, 4, 4, 3, 3, 2, 2, 1, 1]
      sum = values.zip(weights).sum do |value, weight|
        value * weight
      end

      # sum = values.sum
      avg = values.empty? ? 0 : (sum.to_f / values.size).round(2)

      result[string_key] = { last_10_values: values, sum: sum, avg: avg, photo: player["photo_name"], name: player["name"] }
    end

    # Sort by average descending
    @sorted_result = result.sort_by { |_, v| -v[:avg] }.to_h


    solo_test_max_avg
  end


  private 

  def solo_test_max_avg
    max_record = nil

    (1..13).each do |key|
      string_key = key.to_s
      player = @players.find { |p| p["id"] == key }

      # All values (latest first)
      all_values = @points["6"].reverse.map { |h| h[string_key] }.compact

      # Skip if less than 10 entries
      next if all_values.size < 10

      # Loop through all possible 10-value windows
      (0..(all_values.size - 10)).each do |i|
        window = all_values[i, 10]
        # sum = window.sum
        weights = [5, 5, 4, 4, 3, 3, 2, 2, 1, 1]
        sum = window.zip(weights).sum do |value, weight|
          value * weight
        end

        avg = (sum.to_f / window.size).round(2)

        if max_record.nil? || avg > max_record[:avg]
          max_record = {
            player_id: key,
            player_name: player["name"],
            photo: player["photo_name"],
            avg: avg,
            sum: sum,
            values: window
          }
        end
      end
    end

    @highest_ranking = max_record
  end

end
