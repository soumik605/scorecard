# app/services/tournament_setup_service.rb
class TournamentSetupService
  attr_reader :tournament, :players, :teams, :matches, :matches_per_team

  def initialize(tournament, players, matches_per_team)
    @tournament = tournament
    @players = players.shuffle
    @teams = []
    @matches = []
    @matches_per_team = matches_per_team
  end

  def setup_tournament
    matches = []
    player_ids = players.pluck(:id)

    player_ids.combination(2).each do |player1, player2|
      matches_per_team.times do |round|
        matches << { player_1_id: player1, player_2_id: player2 }
      end
    end

    matches = matches.shuffle

    matches.each_with_index do |mt, index|
      p mt
      match = Match.create(tournament_id: tournament.id, match_type: 1)
      Team.create(name: "Team 1", captain_id: mt.stringify_keys["player_1_id"], match_id: match.id)
      Team.create(name: "Team 2", captain_id: mt.stringify_keys["player_2_id"], match_id: match.id)
    end
  end

end


Match.all.each do |m|
  p Player.where(id: m.teams.pluck(:captain_id)).pluck(:name)
  p "_____________________________________"
end