class Player < ApplicationRecord
  has_many :player_teams
  has_many :teams, through: :player_teams
  has_many :performances, dependent: :destroy
  has_many :captain_teams, class_name: 'Team', foreign_key: "captain_id"


  def self.most_runs performances, players
    player_runs = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["runs"].to_i } 
    end
    player_with_most_runs = player_runs.max_by { |player_id, total_runs| total_runs }
    player = players.find{|p| p["id"] == player_with_most_runs[0]}
    return "#{player['name']} (#{player_with_most_runs[1]})"
  end


  def self.most_wickets performances, players
    player_wickets = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["wickets"].to_i } 
    end
    player_with_most_wickets = player_wickets.max_by { |player_id, total_wickets| total_wickets }
    player = players.find{|p| p["id"] == player_with_most_wickets[0]}
    return "#{player['name']} (#{player_with_most_wickets[1]})"
  end


  def self.most_ducks performances, players
    zero_runs = performances.select { |record| record["runs"] == 0 }
    player_zero_counts = zero_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_zeros = player_zero_counts.max_by { |_, count| count }
    player = players.find{|p| p["id"] == player_with_most_zeros[0]}
    return "#{player['name']} (#{player_with_most_zeros[1]})"
  end

  def self.most_fifties performances, players
    fifty_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 50 }
    player_fifty_counts = fifty_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_fiftys = player_fifty_counts.max_by { |_, count| count }
    return "-" unless player_with_most_fiftys.present?
    player = players.find{|p| p["id"] == player_with_most_fiftys[0]}
    return "#{player['name']} (#{player_with_most_fiftys[1]})"
  end
  
  def self.most_hundreds performances, players
    hundread_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 100 }
    player_hundread_counts = hundread_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_hundreads = player_hundread_counts.max_by { |_, count| count }
    return "-" unless player_with_most_hundreads.present?
    player = players.find{|p| p["id"] == player_with_most_hundreads[0]}
    return "#{player['name']} (#{player_with_most_hundreads[1]})"
  end

  def self.captain_win_percentage(order: :desc)
    x = joins("INNER JOIN teams ON teams.captain_id = players.id")
      .joins("LEFT JOIN matches ON matches.winner_team_id = teams.id OR matches.id IS NOT NULL")
      .select("players.id, players.name, 
               COUNT(matches.id) AS total_matches, 
               SUM(CASE WHEN matches.winner_team_id = teams.id THEN 1 ELSE 0 END) AS total_wins,
               SUM(CASE WHEN matches.winner_team_id = teams.id THEN 1 ELSE 0 END) * 100.0 / COUNT(matches.id) AS win_percentage")
      .group("players.id")
      .order("win_percentage #{order == :asc ? 'ASC' : 'DESC'}").first

    return "#{x.name} (#{x.win_percentage})"
  end

  def self.most_wins matches, teams, players
    winning_matches = matches.reject { |match| match["winner_team_id"].nil? }
    captain_wins = Hash.new(0)
    winning_matches.each do |match|
      winner_team = teams.find { |team| team["id"] == match["winner_team_id"] }
      captain_wins[winner_team["captain_id"]] += 1 if winner_team
    end
    most_wins = captain_wins.max_by { |_, wins| wins }
    player = players.find{|p| p["id"] == most_wins[0]}
    return "#{player['name']} (#{most_wins[1]})"
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
