class Player < ApplicationRecord
  has_many :player_teams
  has_many :teams, through: :player_teams
  has_many :performances, dependent: :destroy
  has_many :captain_teams, class_name: 'Team', foreign_key: "captain_id"


  def self.most_runs performances, players
    player_runs = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["runs"].to_i } 
    end
    player_with_most_runs = player_runs.sort_by { |_, total_runs| -total_runs }
    return "-" unless player_with_most_runs.present?

    player = players.find{|p| p["id"] == player_with_most_runs[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_runs[0][1]})</b><br >"
    
    if player_with_most_runs.count > 1
      player = players.find{|p| p["id"] == player_with_most_runs[1][0]}
      text += "#{player['name']} (#{player_with_most_runs[1][1]})"
    end

    return text
  end

  def self.most_wickets performances, players
    player_wickets = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["wickets"].to_i } 
    end
    player_with_most_wickets = player_wickets.sort_by { |player_id, total_wickets| -total_wickets }
    return "-" unless player_with_most_wickets.present?
    player = players.find{|p| p["id"] == player_with_most_wickets[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_wickets[0][1]})</b><br >"

    if player_with_most_wickets.count > 1
      player = players.find{|p| p["id"] == player_with_most_wickets[1][0]}
      text += "#{player['name']} (#{player_with_most_wickets[1][1]})"
    end

    return text
  end

  def self.most_ducks performances, players
    zero_runs = performances.select { |record| record["runs"] == 0 }
    player_zero_counts = zero_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_zeros = player_zero_counts.sort_by { |_, count| -count }
    return "-" unless player_with_most_zeros.present?
    player = players.find{|p| p["id"] == player_with_most_zeros[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_zeros[0][1]})</b><br >"

    if player_with_most_zeros.count > 1
      player = players.find{|p| p["id"] == player_with_most_zeros[1][0]}
      text += "#{player['name']} (#{player_with_most_zeros[1][1]})"
    end

    return text
  end

  def self.most_fifties performances, players
    fifty_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 50 }
    player_fifty_counts = fifty_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_fiftys = player_fifty_counts.sort_by { |_, count| -count }
    return "-" unless player_with_most_fiftys.present?
    player = players.find{|p| p["id"] == player_with_most_fiftys[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_fiftys[0][1]})</b><br >"

    if player_with_most_fiftys.count > 1
      player = players.find{|p| p["id"] == player_with_most_fiftys[1][0]}
      text += "#{player['name']} (#{player_with_most_fiftys[1][1]})"
    end

    return text
  end
  
  def self.most_hundreds performances, players
    hundread_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 100 }
    player_hundread_counts = hundread_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_hundreads = player_hundread_counts.sort_by { |_, count| count }
    return "-" unless player_with_most_hundreads.present?
    player = players.find{|p| p["id"] == player_with_most_hundreads[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_hundreads[0][1]})</b><br >"

    if player_with_most_hundreads.count > 1
      player = players.find{|p| p["id"] == player_with_most_hundreads[1][0]}
      text += "#{player['name']} (#{player_with_most_hundreads[1][1]})"
    end

    return text
  end

  def self.captain_win_percentage(matches, teams, players, type)
    captain_wins = Hash.new(0)
    captain_matches = Hash.new(0)

    matches.each do |match|
      captain_matches[match["captain_a"]] += 1
      captain_matches[match["captain_b"]] += 1
      captain_wins[match["winner_captain_id"]] += 1 if match["winner_captain_id"]
    end

    win_percentages = captain_wins.map do |captain_id, wins|
      total_matches = captain_matches[captain_id]
      [captain_id, (wins.to_f / total_matches * 100).round(2)]
    end.to_h

    captain_win_percent = win_percentages.sort_by { |_, win_percent| -win_percent }
    return "-" unless captain_win_percent.present?

    if type == "best"
      player = players.find{|p| p["id"] == captain_win_percent[0][0]}
      text = "<b>#{player["name"]} (#{captain_win_percent[0][1].to_i}%)</b><br >"
      if captain_win_percent.count > 1
        player = players.find{|p| p["id"] == captain_win_percent[1][0]}
        text += "#{player["name"]} (#{captain_win_percent[1][1].to_i}%)"
      end
    else
      player = players.find{|p| p["id"] == captain_win_percent[-1][0]}
      text = "<b>#{player["name"]} (#{captain_win_percent[-1][1].to_i}%)</b><br >"

      if captain_win_percent.count > 1
        player = players.find{|p| p["id"] == captain_win_percent[-2][0]}
        text += "#{player["name"]} (#{captain_win_percent[-2][1].to_i}%)"
      end
    end

    return text
  end

  def self.captain_most_matches(matches, teams, players)
    captain_match_counts = Hash.new(0)

    matches.each do |match|
      captain_match_counts[match["captain_a"]] += 1
      captain_match_counts[match["captain_b"]] += 1
    end
    captain_most_matches = captain_match_counts.sort_by { |_, count| -count }
    return "-" unless captain_most_matches.present?
    player = players.find{|p| p["id"] == captain_most_matches[0][0]}
    text = "<b>#{player["name"]} (#{captain_most_matches[0][1]})</b><br >"

    if captain_most_matches.count > 1
      player = players.find{|p| p["id"] == captain_most_matches[1][0]}
      text += "#{player["name"]} (#{captain_most_matches[1][1]})"
    end

    return text
  end

  def self.most_wins matches, teams, players
    win_counts = matches.each_with_object(Hash.new(0)) do |match, counts|
      counts[match["winner_captain_id"]] += 1
    end
    
    captain_most_winning = win_counts.sort_by { |captain_id, wins| -wins }
    return "-" unless captain_most_winning.present?

    player = players.find{|p| p["id"] == captain_most_winning[0][0]}
    text = "<b>#{player['name']} (#{captain_most_winning[0][1]})</b><br >"

    if captain_most_winning.count>1
      player = players.find{|p| p["id"] == captain_most_winning[1][0]}
      text += "#{player['name']} (#{captain_most_winning[1][1]})"
    end

    return text
  end
  
  def self.most_series_wins
    joins(teams: { match: :tournament }).where('teams.captain_id = players.id AND matches.winner_team_id = teams.id')
                                        .select('players.id, players.name, COUNT(DISTINCT tournaments.id) AS total_series_wins')
                                        .group('players.id')
                                        .order('total_series_wins DESC')
                                        # .first
                                        # .try(:name)
  end

  

  
end
