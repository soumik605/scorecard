class TournamentsController < ApplicationController
  before_action :get_data
  before_action :set_tournament, only: [:show, :edit, :update, :leaderboard, :head_to_head, :performances, :next_match_suggestion]


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
    @next_matches = Tournament.get_next_match_suggestion(@matches, @players)
  end

  private 

  def set_tournament
    @tour = @tours.find{ |t| t["id"].to_s == params[:id].to_s}
    @matches = @matches.filter{|m| m["tournament_id"].to_s == params[:id].to_s}
  end

  def tournament_params
    params.require(:tournament).permit(:name, :is_removed, :win_point, :draw_point, :innings_win_point, :follow_on_win_point, :round_count, captain_ids: [])
  end

end
