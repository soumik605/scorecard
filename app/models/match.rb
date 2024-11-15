class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :winner_team, class_name: 'Team', optional: true # Winner team reference
  has_many :teams, dependent: :destroy
  has_many :performances, dependent: :destroy

  after_update :add_points_in_teams

  enum :match_type, { 'group stage': 1, 'qualifier1': 2, 'qualifier2': 3, 'final': 4  }

  private 

  def add_points_in_teams
    
    if saved_changes.has_key? 'winner_team_id' and self.winner_team_id.present? and (self.match_type == 1 || self.match_type == "group stage")
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

    create_qualifier_matches
  end

  def create_qualifier_matches
    return if tournament.matches.where(winner_team_id: nil).present?
  
    q1 = tournament.matches.find_by(match_type: 2)
    q2 = tournament.matches.find_by(match_type: 3)
    final = tournament.matches.find_by(match_type: 4)
    player_ids = Team.where(match_id: tournament.matches.pluck(:id)).pluck(:captain_id)

    players = Player.where(id: player_ids)
    players_data = []

    players.each do |player|
      players_data << [player.id, Team.where(match_id: tournament.matches.where(match_type: 1).pluck(:id), captain_id: player.id).pluck(:total_point).compact.select { |x| x.is_a?(Numeric) && x != 0 }.sum]
    end
    players_data = players_data.sort_by { |name, score| [-score, name] }
    
    cap1 = players_data[0][0]
    cap2 = players_data[1][0]
    cap3 = players_data[2][0]

    if q1.nil?
      match = Match.create(tournament_id: tournament.id, match_type: 2)
      Team.create(name: "Team 1", captain_id: cap1, match_id: match.id )
      Team.create(name: "Team 2", captain_id: cap2, match_id: match.id )
    elsif q2.nil? && q1.winner_team_id.present?
      q1_loser_captain_id = q1.teams.where.not(id: q1.winner_team_id).last.captain_id
      match = Match.create(tournament_id: tournament.id, match_type: 3)
      Team.create!(name: "Team 1", captain_id: q1_loser_captain_id, match_id: match.id)
      Team.create!(name: "Team 2", captain_id: cap3, match_id: match.id)
    elsif final.nil? && q1.winner_team_id.present? && q2&.winner_team_id.present?
      match = Match.create(tournament_id: tournament.id, match_type: 4)
      Team.create!(name: "Team 1", captain_id: q1.winner_team.captain_id, match_id: match.id )
      Team.create!(name: "Team 2", captain_id: q2.winner_team.captain_id, match_id: match.id )
    end
  end
  
  
end
