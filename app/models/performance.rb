class Performance
  # belongs_to :match
  # belongs_to :player

  # scope :with_runs, -> { where.not(runs: nil) }
  # scope :with_wickets, -> { where.not(wickets: nil) }
  # scope :ducks, -> { where(runs: 0) }
  # scope :fifties, -> { where('runs >= 50 AND runs < 100') }
  # scope :hundreds, -> { where('runs >= 100') }
  # scope :best_batting, -> { order(runs: :desc) }
  # scope :best_bowling, -> { order(wickets: :desc) }

  def performance_score
    run = runs || 0
    wicket = wickets || 0
    score = run + (wicket * 15) + (is_not_out ? 10 : 0)
    return score
  end

  def self.best_batting_innings performances, players
    valid_data = performances.reject { |record| record["runs"].nil? }
    best_innings = valid_data.sort_by { |record| -record["runs"] }

    return "-" unless best_innings.present?

    player = players.find{|p| p["id"] == best_innings[0]["player_id"]}
    text = "<b>#{player['name']} (#{best_innings[0]["runs"]})</b><br >"

    if best_innings.count > 1
      player = players.find{|p| p["id"] == best_innings[1]["player_id"]}
      text += "#{player['name']} (#{best_innings[1]["runs"]})<br >"
    end

    if best_innings.count > 2
      player = players.find{|p| p["id"] == best_innings[2]["player_id"]}
      text += "#{player['name']} (#{best_innings[2]["runs"]})"
    end

    return text
  end

  def self.best_bowling_innings performances, players
    valid_data = performances.reject { |record| record["wickets"].nil? }
    best_innings = valid_data.sort_by { |record| -record["wickets"] }

    return "-" unless best_innings.present?

    player = players.find{|p| p["id"] == best_innings[0]["player_id"]}
    text = "<b>#{player['name']} (#{best_innings[0]["wickets"]})</b><br >"

    if best_innings.count > 1
      player = players.find{|p| p["id"] == best_innings[1]["player_id"]}
      text += "#{player['name']} (#{best_innings[1]["wickets"]})<br >"
    end

    if best_innings.count > 2
      player = players.find{|p| p["id"] == best_innings[2]["player_id"]}
      text += "#{player['name']} (#{best_innings[2]["wickets"]})"
    end

    return text
  end
  
end
