class Player < ApplicationRecord
  has_many :player_teams
  has_many :teams, through: :player_teams
  has_many :performances, dependent: :destroy
  has_many :captain_teams, class_name: 'Team', foreign_key: "captain_id"


  def self.most_runs
    joins(:performances).select('players.id, players.name, SUM(performances.runs) AS total_runs')
                        .group('players.id')
                        .order('total_runs DESC')
                        .first
                        .try(:name)
  end


  def self.most_wickets
    joins(:performances).select('players.id, players.name, SUM(performances.wickets) AS total_wickets')
                        .group('players.id')
                        .order('total_wickets DESC')
                        .first
                        .try(:name)
  end


  def self.most_ducks
    joins(:performances).where(performances: { runs: 0 })
                        .select('players.id, players.name, COUNT(performances.id) AS total_ducks')
                        .group('players.id')
                        .order('total_ducks DESC')
                        .first
                        .try(:name)
  end

  def self.most_fifties
    joins(:performances).where('performances.runs BETWEEN 50 AND 99')
                        .select('players.id, players.name, COUNT(performances.id) AS total_fifties')
                        .group('players.id')
                        .order('total_fifties DESC')
                        .first
                        .try(:name)
  end
  
  def self.most_hundreds
    joins(:performances).where('performances.runs >= 100')
                        .select('players.id, players.name, COUNT(performances.id) AS total_hundreds')
                        .group('players.id')
                        .order('total_hundreds DESC')
                        .first
                        .try(:name)
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

  def self.most_wins
    x = joins("INNER JOIN teams ON teams.captain_id = players.id").joins("INNER JOIN matches ON matches.winner_team_id = teams.id").select("players.id, players.name, COUNT(matches.id) AS win_count").group("players.id").order("win_count DESC").first
    return "#{x.name} (#{x.win_count})"
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
