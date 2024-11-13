class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :winner_team, class_name: 'Team', optional: true # Winner team reference
  has_many :teams, dependent: :destroy
  has_many :performances, dependent: :destroy

  after_update :add_points_in_teams

  private 

  def add_points_in_teams
    p saved_changes
    if saved_changes.has_key? 'winner_team_id' and self.winner_team_id.present?
      win_point = tournament.win_point
      draw_point = tournament.draw_point
      innings_win_point = is_won_by_innings ? tournament.innings_win_point : 0
      follow_on_win_point = is_won_by_follow_on ? tournament.follow_on_win_point : 0

      teams.each do |t|
        if t.id == self.winner_team_id
          t.update(win_point: win_point, innings_win_point: innings_win_point, follow_on_win_point: follow_on_win_point, total_point: (win_point + innings_win_point + follow_on_win_point))
        else
          t.update(win_point: 0, innings_win_point: -innings_win_point, follow_on_win_point: -follow_on_win_point, total_point: -(innings_win_point+follow_on_win_point))
        end
      end
    end
  end
  
end
