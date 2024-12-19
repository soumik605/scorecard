class Performance < ApplicationRecord
  belongs_to :match
  belongs_to :player

  scope :with_runs, -> { where.not(runs: nil) }
  scope :with_wickets, -> { where.not(wickets: nil) }
  scope :ducks, -> { where(runs: 0) }
  scope :fifties, -> { where('runs >= 50 AND runs < 100') }
  scope :hundreds, -> { where('runs >= 100') }
  scope :best_batting, -> { order(runs: :desc) }
  scope :best_bowling, -> { order(wickets: :desc) }

  def performance_score
    run = runs || 0
    wicket = wickets || 0
    score = run + (wicket * 15) + (is_not_out ? 10 : 0)
    return score
  end

  def self.best_batting_innings performances, players
    valid_data = performances.reject { |record| record["runs"].nil? }
    best_innings = valid_data.max_by { |record| record["runs"] }
    player = players.find{|p| p["id"] == best_innings["player_id"]}
    return "#{player['name']} (#{best_innings["runs"]})"
  end

  def self.best_bowling_innings performances, players
    valid_data = performances.reject { |record| record["wickets"].nil? }
    best_innings = valid_data.max_by { |record| record["wickets"] }
    player = players.find{|p| p["id"] == best_innings["player_id"]}
    return "#{player['name']} (#{best_innings["wickets"]})"
  end
  
end
