class Api::TournamentsController < ApplicationController
  before_action :get_data
  before_action :set_tournament, only: [:show, :leaderboard]


  def index
  end

  def show
    @matches = @matches.sort_by { |match| -match["id"] }
    if @tour["tour_type"] == "super_over"
      @super = @super["#{@tour['id']}"]
    elsif @tour["tour_type"] == "solo_test"
      @points = @points["#{@tour['id']}"]
    end
  end

  def leaderboard    

    if @tour["tour_type"] == "solo_test"
      points_file = File.open "public/stats/points.json"
      @points = JSON.load points_file
      @columns = ["Player", "Points", "Played", "Average"]

      data = @points["#{@tour['id']}"]

      @players_data = {}
      data.each do |hash|
        hash.each do |key, value|
          @players_data[key] ||= { sum: 0, count: 0 }
          @players_data[key][:sum] += value
          @players_data[key][:count] += 1
        end
      end

      @players_data.each do |key, val|
        val[:average] = val[:sum].to_f / val[:count]
      end

      @players_data = @players_data.sort_by { |_, v| -v[:average] }.to_h

      player_series = Hash.new { |h, k| h[k] = { sum: 0, count: 0, data: {} } }
      data.each do |match|
        match.each do |player_id, value|
          player = player_series[player_id]
          player[:sum] += value
          player[:count] += 1
          avg = player[:sum].to_f / player[:count]
          player[:data]["#{player[:count]}"] = avg
        end
      end

      @players_data = @players_data.map do |player_id, data|
        player = @players.find{|p| p["id"].to_s == player_id.to_s}
        [ player["name"], data[:sum], data[:count], data[:average]  ]
      end

      @player_chart_data = player_series.map do |player_id, val|
        player = @players.find{|p| p["id"].to_s == player_id.to_s }
        { name: player["name"], data: val[:data] }
      end

    elsif @tour["tour_type"] == "super_over"
      @columns = ["Player", "Win", "Played", "Win Percent"]
      data = @super["#{@tour['id']}"]

      @players_data = {}
      data.each do |oa|
        oa.each_with_index do |ia, index|
          
          if index == 0
            ia.each do |id|
              @players_data[id] ||= { win: 0, match: 0 }
              @players_data[id][:match] += 1
              @players_data[id][:win] += 1
            end
          else
            ia.each do |id|
              @players_data[id] ||= { win: 0, match: 0 }
              @players_data[id][:match] += 1
            end
          end
        end

      end
      
      @players_data.each do |key, val|
        val[:percent] =( val[:win].to_f / val[:match])*100
      end
      
      @players_data = @players_data.sort_by { |_, v| -v[:percent] }.to_h

      @players_data = @players_data.map do |player_id, data|
        player = @players.find{|p| p["id"].to_s == player_id.to_s}
        [ player["name"], data[:win], data[:match], data[:percent]  ]
      end

    else
      @columns = ["Player", "Points", "Win", "Played", "Win Percent"]
      @players_data = []
      captain_ids = @matches.pluck("captain_a", "captain_b").flatten.map(&:to_s)
      @players = @players.filter{|p| captain_ids.include? p["id"].to_s }
  
      @players.each do |player|
        player_matches = @matches.filter{|m| [m["captain_a"], m["captain_b"]].include? player["id"]  }
        win_matches = player_matches.filter{|m| m["winner_captain_id"].present? && m["winner_captain_id"] == player["id"] }
        loose_matches = player_matches.filter{|m| m["winner_captain_id"].present? && m["winner_captain_id"] != player["id"] }
        win_point = win_matches.pluck("win_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
        loose_point = loose_matches.pluck("loose_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
        win_percent = player_matches.present? ? (win_matches.count.to_f / player_matches.count.to_f) * 100 : 0
        
        win_percent = "#{win_percent.try(:round)}%"
        win_match_count = win_matches.count
        total_match_count = player_matches.count
        total_point = win_point+loose_point
  
        @players_data << [player["photo_name"], total_point, win_match_count, total_match_count, win_percent ]
      end
  
      @players_data = @players_data.sort_by { |photo_name, point, win, total, per| [-point, total, photo_name] }
    end

  end

  def head_to_head
    @head_to_head = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = { wins: 0, losses: 0 } } }

    @matches.each do |match|
      captain_a = match["captain_a"]
      captain_b = match["captain_b"]
      winner = match["winner_captain_id"]
    
      if winner == captain_a
        @head_to_head[captain_a][captain_b][:wins] += 1
        @head_to_head[captain_b][captain_a][:losses] += 1
      elsif winner == captain_b
        @head_to_head[captain_b][captain_a][:wins] += 1
        @head_to_head[captain_a][captain_b][:losses] += 1
      end
    end
  end


  private 

  def set_tournament
    @tour = @tours.find{ |t| t["id"].to_s == params[:id].to_s}
    @matches = @matches.filter{|m| m["tournament_id"].to_s == params[:id].to_s}
  end
  

end
