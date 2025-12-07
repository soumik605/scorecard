class Match
  # belongs_to :tournament
  # belongs_to :winner_team, class_name: 'Team', optional: true # Winner team reference
  # has_many :teams, dependent: :destroy
  # has_many :performances, dependent: :destroy

  # after_update :add_points_in_teams

  # enum :match_type, { 'group stage': 1, 'qualifier1': 2, 'qualifier2': 3, 'final': 4  }
  
  # scope :won_by_innings, -> { where(is_won_by_innings: true) }
  # scope :won_by_follow_on, -> { where(is_won_by_follow_on: true) }
  # scope :drawn, -> { where(is_draw: true) }

  def self.most_wins_by_innings matches, players
    captain_follow_on_wins = Hash.new(0)
    matches.each do |match|
      if match["is_won_by_innings"] && match["winner_captain_id"]
        captain_follow_on_wins[match["winner_captain_id"]] += 1
      end
    end

    sorted_captains = captain_follow_on_wins.sort_by { |_, count| -count }
    player = players.find{|p| p["id"] == sorted_captains[0][0]}
    text =  "<b>#{player["name"]} (#{sorted_captains[0][1]})</b><br >"

    if sorted_captains.count > 1
      player = players.find{|p| p["id"] == sorted_captains[1][0]}
      text +=  "#{player["name"]} (#{sorted_captains[1][1]})<br >"
    end

    if sorted_captains.count > 2
      player = players.find{|p| p["id"] == sorted_captains[2][0]}
      text +=  "#{player["name"]} (#{sorted_captains[2][1]})"
    end

    return text
  end


  def self.most_wins_by_follow_on matches, players
    captain_follow_on_wins = Hash.new(0)
    matches.each do |match|
      if match["is_won_by_follow_on"] && match["winner_captain_id"]
        captain_follow_on_wins[match["winner_captain_id"]] += 1
      end
    end

    sorted_captains = captain_follow_on_wins.sort_by { |_, count| -count }
    player = players.find{|p| p["id"] == sorted_captains[0][0]}
    text =  "<b>#{player["name"]} (#{sorted_captains[0][1]})</b><br >"

    if sorted_captains.count > 1
      player = players.find{|p| p["id"] == sorted_captains[1][0]}
      text +=  "#{player["name"]} (#{sorted_captains[1][1]})<br >"
    end

    if sorted_captains.count > 2
      player = players.find{|p| p["id"] == sorted_captains[2][0]}
      text +=  "#{player["name"]} (#{sorted_captains[2][1]})"
    end

    return text
  end

  def self.best_win_percent_against_captain matches, players
    match_stats = Hash.new { |hash, key| hash[key] = { total_matches: 0, wins: 0 } }
    matches.each do |match|
      player_a = match["captain_a"]
      player_b = match["captain_b"]
      winner = match["winner_captain_id"]

      match_stats[[player_a, player_b]][:total_matches] += 1
      match_stats[[player_b, player_a]][:total_matches] += 1

      match_stats[[winner, player_a == winner ? player_b : player_a]][:wins] += 1
    end

    win_percentages = match_stats
                      .select { |_, stats| stats[:total_matches] >= 5 }
                      .map do |(winner, loser), stats|
                        {
                          player_id: winner,
                          against: loser,
                          win_percentage: (stats[:wins].to_f / stats[:total_matches]) * 100
                        }
                      end

    best_players = win_percentages.sort_by { |entry| -entry[:win_percentage] }

    text = "-"
    if best_players.present?
      player = players.find{|p| p["id"] == best_players[0][:player_id]}
      against = players.find{|p| p["id"] == best_players[0][:against]}
      text =  "<b>#{player["name"]} (#{best_players[0][:win_percentage].round(2)}%) vs #{against["name"]}</b><br >"
  
      if best_players.size >= 2
        player = players.find{|p| p["id"] == best_players[1][:player_id]}
        against = players.find{|p| p["id"] == best_players[1][:against]}
        text +=  "#{player["name"]} (#{best_players[1][:win_percentage].round(2)}%) vs #{against["name"]}<br >"
      end

      if best_players.size >= 3
        player = players.find{|p| p["id"] == best_players[2][:player_id]}
        against = players.find{|p| p["id"] == best_players[2][:against]}
        text +=  "#{player["name"]} (#{best_players[2][:win_percentage].round(2)}%) vs #{against["name"]}"
      end
    end
    


    # if best_players.size >= 2
    #   puts "Best: Player #{best_players[0][:player_id]} with #{best_players[0][:win_percentage].round(2)}% win against Player #{best_players[0][:against]}"
    #   puts "Second Best: Player #{best_players[1][:player_id]} with #{best_players[1][:win_percentage].round(2)}% win against Player #{best_players[1][:against]}"
    # else
    #   puts "Not enough data for minimum 4 matches to determine best and second best."
    # end

    return text
  end

  def player_of_the_match
    if winner_team.present?
      data = {}
      Player.all.each do |player|
        perfs = performances.where(player_id: player)
        if perfs.present?
          sum = 0
          perfs.each do |p|
            sum += p.performance_score
          end
          data ["#{player.name}"] = sum
        end
      end

      name = data.present? ? data.max_by { |_, value| value }[0] : ""
      return name
    else
      return nil
    end
  end
  
  private 

  def add_points_in_teams
    
    if saved_changes.has_key? 'winner_team_id' and self.winner_team_id.present? and (self.match_type == 1 || self.match_type == "group stage")
      win_point = tournament.win_point
      draw_point = tournament.draw_point
      innings_win_point = is_won_by_innings ? tournament.innings_win_point : 0
      follow_on_win_point = is_won_by_follow_on ? tournament.follow_on_win_point : 0

      teams.each do |t|
        if t.id == self.winner_team_id
          t.update(win_point: win_point, innings_win_point: innings_win_point, follow_on_win_point: follow_on_win_point, total_point: (win_point + innings_win_point + follow_on_win_point))
        else
          t.update(win_point: 0, innings_win_point: -innings_win_point, follow_on_win_point: -follow_on_win_point, total_point: -(innings_win_point+follow_on_win_point))
        end
      end
    end

    create_qualifier_matches
  end

  def create_qualifier_matches
    return if tournament.matches.where(winner_team_id: nil).present?
  
    q1 = tournament.matches.find_by(match_type: 2)
    q2 = tournament.matches.find_by(match_type: 3)
    final = tournament.matches.find_by(match_type: 4)
    player_ids = Team.where(match_id: tournament.matches.pluck(:id)).pluck(:captain_id)

    players = Player.where(id: player_ids)
    players_data = []

    players.each do |player|
      players_data << [player.id, Team.where(match_id: tournament.matches.where(match_type: 1).pluck(:id), captain_id: player.id).pluck(:total_point).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end
    players_data = players_data.sort_by { |name, score| [-score, name] }
    
    cap1 = players_data[0][0]
    cap2 = players_data[1][0]
    cap3 = players_data[2][0]

    if q1.nil?
      match = Match.create(tournament_id: tournament.id, match_type: 2)
      Team.create(name: "Team 1", captain_id: cap1, match_id: match.id )
      Team.create(name: "Team 2", captain_id: cap2, match_id: match.id )
    elsif q2.nil? && q1.winner_team_id.present?
      q1_loser_captain_id = q1.teams.where.not(id: q1.winner_team_id).last.captain_id
      match = Match.create(tournament_id: tournament.id, match_type: 3)
      Team.create!(name: "Team 1", captain_id: q1_loser_captain_id, match_id: match.id)
      Team.create!(name: "Team 2", captain_id: cap3, match_id: match.id)
    elsif final.nil? && q1.winner_team_id.present? && q2&.winner_team_id.present?
      match = Match.create(tournament_id: tournament.id, match_type: 4)
      Team.create!(name: "Team 1", captain_id: q1.winner_team.captain_id, match_id: match.id )
      Team.create!(name: "Team 2", captain_id: q2.winner_team.captain_id, match_id: match.id )
    end
  end
  
  
end
