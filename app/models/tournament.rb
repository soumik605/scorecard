class Tournament
  # has_many :matches, dependent: :destroy

  # after_create :create_matches

  # attr_accessor :captain_ids

  # validate :check_captain_count

  # enum :tour_type, { 'test': 1, 't20': 2  }
  
  
  def self.get_next_match_suggestion(matches, players)
    all_matches = matches.map(&:dup) # Avoid mutating original
    active_player_ids = [1, 2, 3, 4, 5]
    current_tournament_id = 4
    penalty_weight = 3

    next_matches = []

    20.times do
      overall_matchup_count = Hash.new(0)
      current_tournament_matchup_count = Hash.new(0)

      all_matches.each do |match|
        pair = [match["captain_a"], match["captain_b"]].sort
        overall_matchup_count[pair] += 1

        if match["tournament_id"] == current_tournament_id
          current_tournament_matchup_count[pair] += 1
        end
      end

      # Compute scores for each possible pair
      candidate_scores = []
      active_player_ids.combination(2).each do |pair|
        overall = overall_matchup_count[pair] || 0
        current = current_tournament_matchup_count[pair] || 0
        score = overall + (current * penalty_weight)
        candidate_scores << { pair: pair, score: score, overall: overall, current: current }
      end

      candidate_scores = candidate_scores.shuffle

      # Pick pair with lowest score
      selected = candidate_scores.min_by { |c| c[:score] }
      pair = selected[:pair]

      # Append the simulated match to all_matches
      all_matches << {
        "captain_a" => pair[0],
        "captain_b" => pair[1],
        "tournament_id" => current_tournament_id
      }

      # Get names for output
      player_a_name = players.find { |p| p["id"] == pair[0] }["photo_name"]
      player_b_name = players.find { |p| p["id"] == pair[1] }["photo_name"]

      next_matches << [[player_a_name, player_b_name], selected[:overall], selected[:current]]
    end

    next_matches
  end



  def self.get_toughest_rivalry matches
    rivalries = Hash.new { |h, k| h[k] = { total: 0, wins: Hash.new(0) } }

    matches.each do |match|
      a, b = match["captain_a"], match["captain_b"]
      key = [a, b].sort
      rivalry = rivalries[key]
      rivalry[:total] += 1
      rivalry[:wins][match["winner_captain_id"]] += 1
    end

    # Filter rivalries with at least 10 matches and sort by win difference
    result = rivalries.select { |_, v| v[:total] >= 10 }
      .map do |(a, b), data|
        wins = data[:wins]
        win_counts = [[a, wins[a] || 0], [b, wins[b] || 0]]
        win_diff = (win_counts[0][1] - win_counts[1][1]).abs

        {
          pair: [a, b],
          total_match: data[:total],
          win_diff: win_diff,
          player_a: { id: win_counts[0][0], win: win_counts[0][1] },
          player_b: { id: win_counts[1][0], win: win_counts[1][1] }
        }
      end
      .sort_by { |entry| entry[:win_diff] }

    # Convert to desired hash structure
    formatted_result = {}
    result.each_with_index do |entry, i|
      formatted_result[(i+1).to_s] = {
        "total_match" => entry[:total_match],
        "player_a" => entry[:player_a],
        "player_b" => entry[:player_b]
      }
    end

    return formatted_result
  end

  private 

  # def check_captain_count
  #   unless self.matches.present?
  #     self.errors.add(:base, "Add captains.") and return unless self.captain_ids.present?
  #     self.errors.add(:base, "Add minimum 3 captains.") and return if self.captain_ids.count < 3
  #   end
  # end

  def create_matches
    # service = TournamentSetupService.new(self, Player.where(id: self.captain_ids), round_count)
    # service.setup_tournament
  end
end
