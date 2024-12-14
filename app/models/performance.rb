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

  def self.best_batting_innings
    p = Performance.with_runs.order('runs DESC').first
    return "#{p.runs} (#{p.player.name})"
  end

  def self.best_bowling_innings
    p = Performance.with_runs.order('wickets DESC').first
    return "#{p.runs} (#{p.player.name})"
  end
  
end
