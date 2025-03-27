class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy

  after_create :create_matches

  attr_accessor :captain_ids

  validate :check_captain_count

  enum :tour_type, { 'test': 1, 't20': 2  }
  
  
  def self.get_next_match_suggestion(matches, players)
    all_matches = matches
    active_player_ids = [1, 2, 3, 4, 5]

    next_matches = []

    20.times do
      match_count = Hash.new(0)
      matchup_count = Hash.new(0)
  
      all_matches.each do |match|
        pair = [match["captain_a"], match["captain_b"]].sort
        matchup_count[pair] += 1
        match_count[match["captain_a"]] += 1 if active_player_ids.include?(match["captain_a"])
        match_count[match["captain_b"]] += 1 if active_player_ids.include?(match["captain_b"])
      end
     
      l_captain = match_count.group_by{|k, v| v}.min_by{|k, v| k}.last.to_h
      l_captain_matchups = matchup_count.select { |k, _| k.include?(l_captain.keys[0]) }
      min_matchup = l_captain_matchups.select { |k, _| active_player_ids.include?(k[0]) && active_player_ids.include?(k[1]) }.min_by { |_, v| v }
      
      player_a_name = players.find {|p| p["id"] == min_matchup[0][0]}["photo_name"]
      player_b_name = players.find {|p| p["id"] == min_matchup[0][1]}["photo_name"]
      next_matches << [[player_a_name, player_b_name], min_matchup[1]]
      all_matches << { "captain_a" => min_matchup[0][0], "captain_b" => min_matchup[0][1] }
    end  

    next_matches
  end

  private 

  def check_captain_count
    unless self.matches.present?
      self.errors.add(:base, "Add captains.") and return unless self.captain_ids.present?
      self.errors.add(:base, "Add minimum 3 captains.") and return if self.captain_ids.count < 3
    end
  end

  def create_matches
    service = TournamentSetupService.new(self, Player.where(id: self.captain_ids), round_count)
    service.setup_tournament
  end
end
