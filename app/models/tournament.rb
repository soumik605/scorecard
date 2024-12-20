class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy

  after_create :create_matches

  attr_accessor :captain_ids

  validate :check_captain_count

  enum :tour_type, { 'test': 1, 't20': 2  }

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
