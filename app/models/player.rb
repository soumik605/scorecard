class Player < ApplicationRecord
  has_many :player_teams
  has_many :teams, through: :player_teams
  has_many :performances, dependent: :destroy
  has_many :captain_teams, class_name: 'Team', foreign_key: "captain_id"


  def self.most_average_as_player(performances, matches, players, is_captain)
    captain_matches = {}
    matches.each do |match|
      captain_matches[match["captain_a"]] ||= []
      captain_matches[match["captain_a"]] << match["id"]
      captain_matches[match["captain_b"]] ||= []
      captain_matches[match["captain_b"]] << match["id"]
    end
  
    captain_averages = {}
  
    # Collect total runs and innings count per player
    performances.each do |performance|
      captain_matches.each do |captain_id, match_ids|
        if is_captain
          if match_ids.include?(performance["match_id"])
            if performance["player_id"] == captain_id
              captain_averages[captain_id] ||= { total_runs: 0, innings: 0 }
              if performance["runs"].present?
                captain_averages[captain_id][:total_runs] += performance["runs"]
                captain_averages[captain_id][:innings] += 1
              end
            end
          end
        else
          unless match_ids.include?(performance["match_id"])
            if performance["player_id"] == captain_id
              captain_averages[captain_id] ||= { total_runs: 0, innings: 0 }
              if performance["runs"].present?
                captain_averages[captain_id][:total_runs] += performance["runs"]
                captain_averages[captain_id][:innings] += 1
              end
            end
          end
        end
      end
    end
  
    # Calculate averages (avoid division by zero)
    captain_averages.each do |captain_id, data|
      data[:average] = data[:innings].zero? ? 0 : (data[:total_runs].to_f / data[:innings])
    end
  
    most_average_captains = captain_averages.sort_by { |_, data| -data[:average] }
  
    return "-" unless most_average_captains.present?
  
    player = players.find { |p| p["id"] == most_average_captains[0][0] }
    text = "<b>#{player['name']} (#{most_average_captains[0][1][:average].round(2)})</b><br >"
  
    if most_average_captains.count > 1
      player = players.find { |p| p["id"] == most_average_captains[1][0] }
      text += "#{player['name']} (#{most_average_captains[1][1][:average].round(2)})<br >"
    end
  
    if most_average_captains.count > 2
      player = players.find { |p| p["id"] == most_average_captains[2][0] }
      text += "#{player['name']} (#{most_average_captains[2][1][:average].round(2)})"
    end
  
    return text
  end
  

  def self.most_runs performances, players
    player_runs = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["runs"].to_i } 
    end
    player_with_most_runs = player_runs.sort_by { |_, total_runs| -total_runs }
    return "-" unless player_with_most_runs.present?

    player = players.find{|p| p["id"] == player_with_most_runs[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_runs[0][1]})</b><br >"
    
    if player_with_most_runs.count > 1
      player = players.find{|p| p["id"] == player_with_most_runs[1][0]}
      text += "#{player['name']} (#{player_with_most_runs[1][1]})<br >"
    end

    if player_with_most_runs.count > 2
      player = players.find{|p| p["id"] == player_with_most_runs[2][0]}
      text += "#{player['name']} (#{player_with_most_runs[2][1]})"
    end

    return text
  end

  def self.most_wickets performances, players
    player_wickets = performances.group_by { |entry| entry["player_id"] }.transform_values do |entries|
      entries.sum { |entry| entry["wickets"].to_i } 
    end
    player_with_most_wickets = player_wickets.sort_by { |player_id, total_wickets| -total_wickets }
    return "-" unless player_with_most_wickets.present?
    player = players.find{|p| p["id"] == player_with_most_wickets[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_wickets[0][1]})</b><br >"

    if player_with_most_wickets.count > 1
      player = players.find{|p| p["id"] == player_with_most_wickets[1][0]}
      text += "#{player['name']} (#{player_with_most_wickets[1][1]})<br >"
    end

    if player_with_most_wickets.count > 2
      player = players.find{|p| p["id"] == player_with_most_wickets[2][0]}
      text += "#{player['name']} (#{player_with_most_wickets[2][1]})"
    end

    return text
  end

  def self.most_ducks performances, players
    zero_runs = performances.select { |record| record["runs"] == 0 }
    player_zero_counts = zero_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_zeros = player_zero_counts.sort_by { |_, count| -count }
    return "-" unless player_with_most_zeros.present?
    player = players.find{|p| p["id"] == player_with_most_zeros[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_zeros[0][1]})</b><br >"

    if player_with_most_zeros.count > 1
      player = players.find{|p| p["id"] == player_with_most_zeros[1][0]}
      text += "#{player['name']} (#{player_with_most_zeros[1][1]})<br >"
    end

    if player_with_most_zeros.count > 2
      player = players.find{|p| p["id"] == player_with_most_zeros[2][0]}
      text += "#{player['name']} (#{player_with_most_zeros[2][1]})"
    end

    return text
  end

  def self.most_fifties performances, players
    fifty_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 50 }
    player_fifty_counts = fifty_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_fiftys = player_fifty_counts.sort_by { |_, count| -count }
    return "-" unless player_with_most_fiftys.present?
    player = players.find{|p| p["id"] == player_with_most_fiftys[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_fiftys[0][1]})</b><br >"

    if player_with_most_fiftys.count > 1
      player = players.find{|p| p["id"] == player_with_most_fiftys[1][0]}
      text += "#{player['name']} (#{player_with_most_fiftys[1][1]})<br >"
    end

    if player_with_most_fiftys.count > 2
      player = players.find{|p| p["id"] == player_with_most_fiftys[2][0]}
      text += "#{player['name']} (#{player_with_most_fiftys[2][1]})"
    end

    return text
  end
  
  def self.most_hundreds performances, players
    hundread_runs = performances.select { |record| record["runs"].present? && record["runs"] >= 100 }
    player_hundread_counts = hundread_runs.group_by { |record| record["player_id"] }.transform_values(&:count)
    player_with_most_hundreads = player_hundread_counts.sort_by { |_, count| count }
    return "-" unless player_with_most_hundreads.present?
    player = players.find{|p| p["id"] == player_with_most_hundreads[0][0]}
    text = "<b>#{player['name']} (#{player_with_most_hundreads[0][1]})</b><br >"

    if player_with_most_hundreads.count > 1
      player = players.find{|p| p["id"] == player_with_most_hundreads[1][0]}
      text += "#{player['name']} (#{player_with_most_hundreads[1][1]})<br >"
    end

    if player_with_most_hundreads.count > 2
      player = players.find{|p| p["id"] == player_with_most_hundreads[2][0]}
      text += "#{player['name']} (#{player_with_most_hundreads[2][1]})"
    end

    return text
  end

  def self.captain_win_percentage(matches, teams, players, type)
    captain_wins = Hash.new(0)
    captain_matches = Hash.new(0)

    matches.each do |match|
      captain_matches[match["captain_a"]] += 1
      captain_matches[match["captain_b"]] += 1
      captain_wins[match["winner_captain_id"]] += 1 if match["winner_captain_id"]
    end

    win_percentages = captain_wins.map do |captain_id, wins|
      total_matches = captain_matches[captain_id]
      [captain_id, (wins.to_f / total_matches * 100).round(2)]
    end.to_h

    captain_win_percent = win_percentages.sort_by { |_, win_percent| -win_percent }
    return "-" unless captain_win_percent.present?

    if type == "best"
      player = players.find{|p| p["id"] == captain_win_percent[0][0]}
      text = "<b>#{player["name"]} (#{captain_win_percent[0][1].try(:round)}%)</b><br >"
      if captain_win_percent.count > 1
        player = players.find{|p| p["id"] == captain_win_percent[1][0]}
        text += "#{player["name"]} (#{captain_win_percent[1][1].try(:round)}%)<br >"
      end
      if captain_win_percent.count > 2
        player = players.find{|p| p["id"] == captain_win_percent[2][0]}
        text += "#{player["name"]} (#{captain_win_percent[2][1].try(:round)}%)"
      end
    else
      player = players.find{|p| p["id"] == captain_win_percent[-1][0]}
      text = "<b>#{player["name"]} (#{captain_win_percent[-1][1].try(:round)}%)</b><br >"

      if captain_win_percent.count > 1
        player = players.find{|p| p["id"] == captain_win_percent[-2][0]}
        text += "#{player["name"]} (#{captain_win_percent[-2][1].try(:round)}%)<br >"
      end
      if captain_win_percent.count > 2
        player = players.find{|p| p["id"] == captain_win_percent[-3][0]}
        text += "#{player["name"]} (#{captain_win_percent[-3][1].try(:round)}%)"
      end
    end

    return text
  end

  def self.captain_most_matches(matches, teams, players)
    captain_match_counts = Hash.new(0)

    matches.each do |match|
      captain_match_counts[match["captain_a"]] += 1
      captain_match_counts[match["captain_b"]] += 1
    end
    captain_most_matches = captain_match_counts.sort_by { |_, count| -count }
    return "-" unless captain_most_matches.present?
    player = players.find{|p| p["id"] == captain_most_matches[0][0]}
    text = "<b>#{player["name"]} (#{captain_most_matches[0][1]})</b><br >"

    if captain_most_matches.count > 1
      player = players.find{|p| p["id"] == captain_most_matches[1][0]}
      text += "#{player["name"]} (#{captain_most_matches[1][1]})<br >"
    end

    if captain_most_matches.count > 2
      player = players.find{|p| p["id"] == captain_most_matches[2][0]}
      text += "#{player["name"]} (#{captain_most_matches[2][1]})"
    end

    return text
  end

  def self.most_wins matches, teams, players
    win_counts = matches.each_with_object(Hash.new(0)) do |match, counts|
      counts[match["winner_captain_id"]] += 1
    end
    
    captain_most_winning = win_counts.sort_by { |captain_id, wins| -wins }
    return "-" unless captain_most_winning.present?

    player = players.find{|p| p["id"] == captain_most_winning[0][0]}
    text = "<b>#{player['name']} (#{captain_most_winning[0][1]})</b><br >"

    if captain_most_winning.count>1
      player = players.find{|p| p["id"] == captain_most_winning[1][0]}
      text += "#{player['name']} (#{captain_most_winning[1][1]})<br >"
    end

    if captain_most_winning.count>2
      player = players.find{|p| p["id"] == captain_most_winning[2][0]}
      text += "#{player['name']} (#{captain_most_winning[2][1]})"
    end

    return text
  end
  
  def self.most_series_wins
    joins(teams: { match: :tournament }).where('teams.captain_id = players.id AND matches.winner_team_id = teams.id')
                                        .select('players.id, players.name, COUNT(DISTINCT tournaments.id) AS total_series_wins')
                                        .group('players.id')
                                        .order('total_series_wins DESC')
                                        # .first
                                        # .try(:name)
  end

  def self.most_run_as_player performances, matches, players, is_captain
    captain_matches = {}
    matches.each do |match|
      captain_matches[match["captain_a"]] ||= []
      captain_matches[match["captain_a"]] << match["id"]
      captain_matches[match["captain_b"]] ||= []
      captain_matches[match["captain_b"]] << match["id"]
    end

    captain_runs = Hash.new(0)
    performances.each do |performance|
      captain_matches.each do |captain_id, match_ids|
        if is_captain
          if match_ids.include?(performance["match_id"])
            captain_runs[captain_id] += performance["runs"] if performance["player_id"] == captain_id && performance["runs"].present?
          end
        else
          unless match_ids.include?(performance["match_id"])
            captain_runs[captain_id] += performance["runs"] if performance["player_id"] == captain_id && performance["runs"].present?
          end
        end
      end
    end

    most_runs_captain = captain_runs.sort_by { |_, runs| -runs }
    return "-" unless most_runs_captain.present?

    player = players.find{|p| p["id"] == most_runs_captain[0][0]}
    text = "<b>#{player['name']} (#{most_runs_captain[0][1]})</b><br >"

    if most_runs_captain.count>1
      player = players.find{|p| p["id"] == most_runs_captain[1][0]}
      text += "#{player['name']} (#{most_runs_captain[1][1]})<br >"
    end

    if most_runs_captain.count>2
      player = players.find{|p| p["id"] == most_runs_captain[2][0]}
      text += "#{player['name']} (#{most_runs_captain[2][1]})"
    end

    return text
  end

  def self.most_wicket_as_player performances, matches, players, is_captain
    captain_matches = {}
    matches.each do |match|
      captain_matches[match["captain_a"]] ||= []
      captain_matches[match["captain_a"]] << match["id"]
      captain_matches[match["captain_b"]] ||= []
      captain_matches[match["captain_b"]] << match["id"]
    end

    captain_wickets = Hash.new(0)
    performances.each do |performance|
      captain_matches.each do |captain_id, match_ids|
        if is_captain
          if match_ids.include?(performance["match_id"])
            captain_wickets[captain_id] += performance["wickets"] if performance["player_id"] == captain_id && performance["wickets"].present?
          end
        else
          unless match_ids.include?(performance["match_id"])
            captain_wickets[captain_id] += performance["wickets"] if performance["player_id"] == captain_id && performance["wickets"].present?
          end
        end
      end
    end

    most_wickets_captain = captain_wickets.sort_by { |_, wickets| -wickets }
    return "-" unless most_wickets_captain.present?

    player = players.find{|p| p["id"] == most_wickets_captain[0][0]}
    text = "<b>#{player['name']} (#{most_wickets_captain[0][1]})</b><br >"

    if most_wickets_captain.count>1
      player = players.find{|p| p["id"] == most_wickets_captain[1][0]}
      text += "#{player['name']} (#{most_wickets_captain[1][1]})<br >"
    end

    if most_wickets_captain.count>2
      player = players.find{|p| p["id"] == most_wickets_captain[2][0]}
      text += "#{player['name']} (#{most_wickets_captain[2][1]})"
    end

    return text
  end

  def self.most_consicutive_innings_without_duck performances, players
    streaks = Hash.new { |hash, key| hash[key] = { current_streak: 0, max_streak: 0 } }

    performances.each do |entry|
      player_id = entry["player_id"]
      runs = entry["runs"]
      next unless runs.present?

      if runs > 0
        streaks[player_id][:current_streak] += 1
        streaks[player_id][:max_streak] = [streaks[player_id][:current_streak], streaks[player_id][:max_streak]].max
      else
        streaks[player_id][:current_streak] = 0
      end
    end

    best_player = streaks.sort_by { |_, stats| -stats[:max_streak] }
    
    player = players.find{|p| p["id"] == best_player[0][0]}
    text = "<b>#{player['name']} (#{best_player[0][1][:max_streak]}), Current: #{best_player[0][1][:current_streak]}</b><br >"

    if best_player.count>1
      player = players.find{|p| p["id"] == best_player[1][0]}
      text += "#{player['name']} (#{best_player[1][1][:max_streak]}), Current: #{best_player[1][1][:current_streak]}<br >"
    end

    if best_player.count>2
      player = players.find{|p| p["id"] == best_player[2][0]}
      text += "#{player['name']} (#{best_player[2][1][:max_streak]}), Current: #{best_player[2][1][:current_streak]}"
    end

    return text
  end



  def self.most_consicutive_win matches, players
    streaks = Hash.new { |hash, key| hash[key] = { current_streak: 0, max_streak: 0 } }

    matches.each do |match|
      captain_a = match["captain_a"]
      captain_b = match["captain_b"]
      winner_captain_id = match["winner_captain_id"]

      if winner_captain_id.to_s == captain_a.to_s
        streaks[captain_a][:current_streak] += 1
        streaks[captain_a][:max_streak] = [streaks[captain_a][:current_streak], streaks[captain_a][:max_streak]].max
      else
        streaks[captain_a][:current_streak] = 0
      end

      if winner_captain_id.to_s == captain_b.to_s
        streaks[captain_b][:current_streak] += 1
        streaks[captain_b][:max_streak] = [streaks[captain_b][:current_streak], streaks[captain_b][:max_streak]].max
      else
        streaks[captain_b][:current_streak] = 0
      end
    end

    best_player = streaks.sort_by { |_, stats| -stats[:max_streak] }
    
    player = players.find{|p| p["id"] == best_player[0][0]}
    text = "<b>#{player['name']} (#{best_player[0][1][:max_streak]}), Current: #{best_player[0][1][:current_streak]}</b><br >"

    if best_player.count>1
      player = players.find{|p| p["id"] == best_player[1][0]}
      text += "#{player['name']} (#{best_player[1][1][:max_streak]}), Current: #{best_player[1][1][:current_streak]}<br >"
    end

    if best_player.count>2
      player = players.find{|p| p["id"] == best_player[2][0]}
      text += "#{player['name']} (#{best_player[2][1][:max_streak]}), Current: #{best_player[2][1][:current_streak]}"
    end

    return text
  end



  def self.batting_ranking performances, players
    performances = performances.filter{|p| p["runs"].present?}
    players_by_id = performances.group_by { |p| p["player_id"] }

    rankings = players_by_id.map do |player_id, innings|
      player = players.find{|p| p["id"].to_s == player_id.to_s}
      last_10 = innings.sort_by { |i| -i["match_id"] }.first(10)
      
      ar = []
      last_10.each do |i|
        run = i["runs"].to_i
        extra_run_point = (run / 3).try(:round)
        extra_max_point = 25
        extra_point = i["is_not_out"] ? [extra_run_point, extra_max_point].min : 0
        point = run + extra_point
        ar << point
      end


         
      {
        player_photo: player["photo_name"],
        player_name: player["name"],
        last_10_scores: last_10.map { |i| "#{i['runs']}#{i["is_not_out"] ? '*' : ''}"  },
        points: ar.sum
      }
    end

    rankings = rankings.sort_by { |r| [-r[:points], -r[:player_name]] }
    return rankings
  end


  def self.highest_batting_ranking(performances, players)
    performances = performances.select { |p| p["runs"].present? }
    players_by_id = performances.group_by { |p| p["player_id"] }

    highest_record = nil

    players_by_id.each do |player_id, innings|
      player = players.find { |p| p["id"].to_s == player_id.to_s }

      sorted_innings = innings.sort_by { |i| -i["match_id"].to_i }

      # Sliding window of 10 matches
      (0..(sorted_innings.size - 10)).each do |i|
        window = sorted_innings[i, 10]

        points = window.sum do |inning|
          runs = inning["runs"].to_i
          extra = inning["is_not_out"] ? [runs / 3, 25].min : 0
          runs + extra
        end

        if highest_record.nil? || points > highest_record[:points]
          highest_record = {
            player_photo: player["photo_name"],
            player_name: player["name"],
            points: points
          }
        end
      end
    end

    return highest_record
  end


  def self.highest_bowling_ranking(performances, players)
    performances = performances.select { |p| p["wickets"].present? }
    players_by_id = performances.group_by { |p| p["player_id"] }

    highest_record = nil

    players_by_id.each do |player_id, innings|
      player = players.find { |p| p["id"].to_s == player_id.to_s }

      sorted_innings = innings.sort_by { |i| -i["match_id"].to_i }

      (0..(sorted_innings.size - 10)).each do |i|
        window = sorted_innings[i, 10]

        points = window.sum { |inning| inning["wickets"].to_i * 15 }

        if highest_record.nil? || points > highest_record[:points]
          highest_record = {
            player_photo: player["photo_name"],
            player_name: player["name"],
            last_10_scores: window.map { |i| i["wickets"] },
            points: points
          }
        end
      end
    end

    return highest_record
  end


  def self.highest_allround_ranking(performances, players)
    performances = performances.select { |p| p["runs"].present? || p["wickets"].present? }
    players_by_id = performances.group_by { |p| p["player_id"] }

    highest_record = nil

    players_by_id.each do |player_id, innings|
      player = players.find { |p| p["id"].to_s == player_id.to_s }
      sorted_innings = innings.sort_by { |i| -i["match_id"].to_i }

      (0..(sorted_innings.size - 10)).each do |i|
        window = sorted_innings[i, 10]

        batting_points = window.sum do |inning|
          runs = inning["runs"].to_i
          extra = inning["is_not_out"] ? [runs / 3, 25].min : 0
          runs + extra
        end

        bowling_points = window.sum { |inning| inning["wickets"].to_i * 15 }

        total_points = batting_points + bowling_points

        if highest_record.nil? || total_points > highest_record[:points]
          highest_record = {
            player_photo: player["photo_name"],
            player_name: player["name"],
            last_10_scores: window.map do |i|
              run_display = i["runs"].present? ? "#{i['runs']}#{i["is_not_out"] ? '*' : ''}" : "-"
              wicket_display = i["wickets"].present? ? "(#{i['wickets']})" : ""
              "#{run_display} #{wicket_display}".strip
            end,
            points: total_points
          }
        end
      end
    end

    return highest_record
  end





  def self.bowling_ranking performances, players
    performances = performances.filter{|p| p["wickets"].present?}
    players_by_id = performances.group_by { |p| p["player_id"] }

    rankings = players_by_id.map do |player_id, innings|
      player = players.find{|p| p["id"].to_s == player_id.to_s}
      last_10 = innings.sort_by { |i| -i["match_id"] }.first(10)
      bowling_points = last_10.sum { |i| i["wickets"].to_i * 15 }
      {
        player_photo: player["photo_name"],
        player_name: player["name"],
        last_10_scores: last_10.map { |i| i["wickets"] },
        points: bowling_points
      }
    end

    rankings = rankings.sort_by { |r| [-r[:points], -r[:player_name]] }
    return rankings
  end

  def self.allround_ranking performances, players
    performances = performances.filter{|p| p["wickets"].present? || p["runs"].present?}
    players_by_id = performances.group_by { |p| p["player_id"] }

    rankings = players_by_id.map do |player_id, innings|
      player = players.find{|p| p["id"].to_s == player_id.to_s}
      last_10 = innings.sort_by { |i| -i["match_id"] }.first(10)

      ar = []
      last_10.each do |i|
        run = i["runs"].to_i
        extra_run_point = (run / 3).try(:round)
        extra_max_point = 25
        extra_point = i["is_not_out"] ? [extra_run_point, extra_max_point].min : 0
        point = run + extra_point
        ar << point
      end
      bowling_points = last_10.sum { |i| i["wickets"].to_i * 15 }
      {
        player_photo: player["photo_name"],
        player_name: player["name"],
        last_10_scores: last_10.map { |i| 
        ["#{i['runs']}#{i["is_not_out"] ? '*' : ''}", i['wickets'].present? ? "(#{i['wickets']})" : ""].join(" ")
      },
        points: ar.sum + bowling_points
      }
    end

    rankings = rankings.sort_by { |r| [-r[:points], -r[:player_name]] }
    return rankings
  end

  
end
