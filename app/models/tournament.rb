class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy

  after_create :create_matches

  private 

  def create_matches
    service = TournamentSetupService.new(self, Player.all, round_count)
    service.setup_tournament
  end
end
