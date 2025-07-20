class TournamentsController < ApplicationController
  before_action :get_data
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard, :head_to_head, :performances, :next_match_suggestion, :chart]


  def index
    @tours = @tours.filter{|t| t["is_removed"].to_s == "false"}.sort_by { |hash| -hash["id"] }
  end

  def show
  end

  def new
    @tournament = Tournament.new
    @players = Player.all
  end

  def create
    @tour = Tournament.new(tournament_params)
    respond_to do |format|
      if @tour.save
        format.turbo_stream { redirect_to tournament_path(@tour), notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @tour.errors.full_messages}
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @tour.update(tournament_params)
        format.turbo_stream { redirect_to tournament_path(@tour), notice: 'Done !!'}
      else
        format.turbo_stream { redirect_to request.referrer, notice: @tour.errors.full_messages}
      end
    end
  end

  def leaderboard    

    if @tour["tour_type"] == "solo_test"
      points_file = File.open "public/stats/points.json"
      @points = JSON.load points_file

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

      @player_chart_data = player_series.map do |player_id, val|
        player = @players.find{|p| p["id"].to_s == player_id.to_s }
        { name: player["name"], data: val[:data] }
      end

    elsif @tour["tour_type"] == "super_over"
      data = @super

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

    else
      @players_data = []
      captain_ids = @matches.pluck("captain_a", "captain_b").flatten.map(&:to_s)
      @players = @players.filter{|p| captain_ids.include? p["id"].to_s }
  
      @players.each do |player|
        player_matches = @matches.filter{|m| [m["captain_a"], m["captain_b"]].include? player["id"]  }
        win_matches = player_matches.filter{|m| m["winner_captain_id"].present? && m["winner_captain_id"] == player["id"] }
        loose_matches = player_matches.filter{|m| m["winner_captain_id"].present? && m["winner_captain_id"] != player["id"] }
        draw_matches = player_matches.filter{|m| !m["winner_captain_id"].present?}
        win_point = win_matches.pluck("win_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
        loose_point = loose_matches.pluck("loose_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
        draw_point = draw_matches.pluck("draw_point").compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum
        win_percent = player_matches.present? ? (win_matches.count.to_f / player_matches.count.to_f) * 100 : 0
        
        win_percent = "#{win_percent.try(:round)}%"
        win_match_count = win_matches.count
        total_match_count = player_matches.count
        total_point = win_point+loose_point+draw_point
  
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

  def performances

  end

  def next_match_suggestion
    @next_matches = Tournament.get_next_match_suggestion(@all_matches, @players)
  end

  def rivalry
    @rivalries = Tournament.get_toughest_rivalry(@matches)
  end

  def create_team
  end
  
  
  def chart
    @players_runs = []

    if @tour["tour_type"] == "solo_test"
      points_file = File.open "public/stats/points.json"
      @points = JSON.load points_file
      
      data = @points["#{@tour['id']}"]
      
      @players.each do |pl|
        player_runs = data.map { |d| d[pl["id"].to_s] }
        player_runs = player_runs.compact
        @players_runs << { name: pl["name"], runs: player_runs, image_url: pl["photo_name"] } if player_runs.present?
      end
    end

    # p @players_runs
  end

  private 

  def set_tournament
    @tour = @tours.find{ |t| t["id"].to_s == params[:id].to_s}

    team_tours = @tours.filter{ |t| ["test", "t10"].include?(t["tour_type"])}
    @all_matches = @matches.filter{|m| team_tours.pluck("id").include?(m["tournament_id"]) }

    @matches = @matches.filter{|m| m["tournament_id"].to_s == params[:id].to_s}
    
    @points = @points[params[:id].to_s]
    @super = @super[params[:id].to_s]
  end

  def tournament_params
    params.require(:tournament).permit(:name, :is_removed, :win_point, :draw_point, :innings_win_point, :follow_on_win_point, :round_count, captain_ids: [])
  end

end
